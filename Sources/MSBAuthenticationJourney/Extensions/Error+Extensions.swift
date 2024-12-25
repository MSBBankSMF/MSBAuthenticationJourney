//
//  Error+Extensions.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//
import BackbaseIdentity

typealias InvalidCredentials = (isIt: Bool, remainingAuthenticationAttempts: Int?)

extension NSError {
    
    /// Returns whether the error was a `.userDisabled` error.
    /// - note: It uses the `Backbase` framework `rootCause()` method to detect the root cause.
    /// - warning: It is not the `.userBlocked` error.
    var isUserPermanentlyDisabled: Bool {
        
        guard let nsRootCauseError = rootCause() as? NSError else { return false }

        guard
            nsRootCauseError.domain == BBIDErrorDomain,
            BBIDErrors(rawValue: nsRootCauseError.code) == .fatalError, // -1059
            [
                .userDisabled,
                .userIsDisabled
            ].contains(nsRootCauseError.localizedDescription)
        else {
            return false
        }

        return true
    }
    
    /// Returns whether the error was a `.userTemporarilyDisabled` error.
    /// - note: It uses the `Backbase` framework `rootCause()` method to detect the root cause.
    var isUserTemporarilyDisabled: Bool {
        
        guard let nsRootCauseError = rootCause() as? NSError else { return false }
    
        guard
            nsRootCauseError.domain == BBIDErrorDomain,
            BBIDErrors(rawValue: nsRootCauseError.code) == .fatalError, // -1059
            [
                .userIsTemporarilyDisabled,
                .userTemporarilyDisabled
            ].contains(nsRootCauseError.localizedDescription)
        else {
            return false
        }
        
        return true
    }
    
    /// Returns whether the error was a `.invalidCredentials` error. The return value contains
    /// the number of remainig attemps. That may be enclosed only when the return value is `true`.
    /// - note: It uses the `Backbase` framework `rootCause()` method to detect the root cause.
    var isInvalidCredentials: InvalidCredentials {
        
        guard let nsRootCauseError = rootCause() as? NSError else { return (false, nil) }
                
        guard
            nsRootCauseError.code == 401, //
            let decodedBody: ErrorDescription.InvalidCredentials = nsRootCauseError.body?.decodeBody(),
            decodedBody.localizedDescription == .invalidCredentials
        else {
            return (false, nil)
        }
        
        return (true, decodedBody.remainingAuthenticationAttempts)
    }

    var isNoValidOTPChannel: Bool {
        guard rootError?.code == BBIDErrors.fatalError.rawValue,
           rootError?.localizedDescription == "no_valid_addresses" else {
            return false
        }

        return true
    }

    // MARK: - Error Descriptions
    
    enum ErrorDescription {
        
        struct InvalidCredentials: Codable {
            
            enum CodingKeys: String, CodingKey {
                case localizedDescription = "error"
                case remainingAuthenticationAttempts
            }
            
            /// Localised description of the error
            let localizedDescription: String
            /// Number of reaming attempts
            /// - note: This value may not be provided
            let remainingAuthenticationAttempts: Int?
        }
    }
}

// MARK: - Verify and convert NSError to auth journey error
extension NSError {
    var rootError: NSError? {
        rootCause() as? NSError
    }
    
    var isIMSDKError: Bool {
        if let rootError = rootError, rootError.domain == BBIDErrorDomain {
            return true
        }
        return false
    }
    
    var authenticationError: MSBAuthenticationJourney.Error? {
        if isIMSDKError,
           let rootError = rootError,
           let error = rootError.userInfo[MSBAuthenticationJourney.Error.Key] as? MSBAuthenticationJourney.Error {
            return error
        }
        return nil
    }
    
    var isNetworkConnectionError: Bool {
        let error = self
        if error.domain == NSURLErrorDomain,
           (error.code == CFNetworkErrors.cfurlErrorTimedOut.rawValue ||
            error.code == CFNetworkErrors.cfurlErrorNetworkConnectionLost.rawValue ||
            error.code == CFNetworkErrors.cfErrorHTTPConnectionLost.rawValue) {
            return true
        }
        return false
    }
}

internal extension NSError {
    var details: [String: Any]? {
        return userInfo["details"] as? [String: Any]
    }

    var headers: [String: String]? {
        return details?["headers"] as? [String: String]
    }

    var body: String? {
        guard let bodyData = details?["body"] as? Data else { return nil }
        return String(data: bodyData, encoding: .utf8)
     }
    
    var jsonBody: [String: Any]? {
        guard let bodyData = details?["body"] as? Data else { return nil }
        return try? JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any]
    }
    
    var authenticateParser: AuthenticateHeaderResponseParser? {
        if let authenticateHeader = headers?["Www-Authenticate"] {
            return AuthenticateHeaderResponseParser(message: authenticateHeader)
        } else if let authenticateBody = body {
            return AuthenticateHeaderResponseParser(jsonMessage: authenticateBody)
        }
        return nil
    }
    
    func jsonUserInfo(forKey key: String) -> [String: AnyObject]? {
        if let data = (userInfo[key] as? String)?.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
            return jsonObject
        }
        return nil
    }
    
    var containsHTMLBody: Bool {
        if let body = body {
            // Regular expression to check if the string is HTML or not
            // Eg:
            // "<div>This is HTML string<div>" // Returns true as its valid HTML string
            // "<div>This is not HTML string" //  Returns false as its not a valid HTML string
            // "This is a string" // Returns false
            return (body.range(of: "<(\"[^\"]*\"|'[^']*'|[^'\">])*>", options: .regularExpression) != nil)
        }
        return false
    }
    
    var isInvalidServerResponse: Bool {
        // BE can send a response with HTML with 500 status code
        // If the status is 200 and HTML body then I-MSDK handles `UnexpectedServerResponse` error
        if containsHTMLBody ||
            (domain == BBIDErrorDomain &&
             code == BBIDErrors.errorUnexpectedServerResponse.rawValue) {
            return true
        }
        return false
    }
    
}
