//
//  Error+OTP+Init.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import Foundation
import BackbaseIdentity
import AppAuth

struct ErrorDescription {
    static let otpLimitExceed = "Otp resend limit exceeded"
    static let incorrectCredentials = "Incorrect credentials"
    static let invalidCredentials = "Invalid user credentials"
    static let invalidGrant = "invalid_grant"
    static let accountIsDisabled = "Account is disabled"
    static let wrongOTP = "wrong otp passcode"
    static let invalidOTP = "INVALID_OTP"
    static let expiredOTP = "EXPIRED_OTP"
}

internal extension MSBAuthenticationJourney.Error {
    init(otp error: Error) {
        defer {
            MSBAuthenticationJourney.Error.logError(self)
        }
        let nsError = error as NSError
        if let error = Self.authenticationParserError(error: nsError) {
            self = error
            return
        }
        
        // ForgotPasscode error handling
        if let rootCauseError = nsError.rootCause() as NSError?,
           rootCauseError.domain == OIDOAuthAuthorizationErrorDomain,
           rootCauseError.code == OIDErrorCodeOAuth.invalidRequest.rawValue,
           let oAuthErrorUserInfo =  rootCauseError.userInfo[OIDOAuthErrorResponseErrorKey] as? [String: String],
           oAuthErrorUserInfo["error_description"] == .invalidCredentials {
                self = .unexpectedError
                return
        }
        self = MSBAuthenticationJourney.Error(sdk: error)
    }
    
    init?(otpError: String) {
        switch otpError {
        case "INVALID_OTP":
            self = .otpAuthIncorrectOTP
        case "EXPIRED_OTP":
            self = .otpAuthExpiredOTP
        default:
            return nil
        }
        return
    }
    
    private static func authenticationParserError (error: NSError) -> MSBAuthenticationJourney.Error? {
        
        guard let authError = error.authenticateParser else {
            return nil
        }
        
        if let error = Self.invalidGrantError(response: authError) {
            return error
        }
        
        if let error = authError.errorType,
           error.contains(ErrorDescription.accountIsDisabled) {
            return .userDisabled
        }
        
        if authError.errorDescription == ErrorDescription.wrongOTP {
            return .otpAuthIncorrectOTP
        }
        
        return authError.otpError
    }
    
    private static func invalidGrantError(response: AuthenticateHeaderResponseParser) -> MSBAuthenticationJourney.Error? {
        if response.errorType == ErrorDescription.invalidGrant {
            if response.errorDescription == ErrorDescription.invalidCredentials {
                return .otpMaxAttemptsReached
            }
            
            if response.errorDescription == ErrorDescription.incorrectCredentials {
                return .otpAuthIncorrectOTP
            }
            
            if let errorDescription = response.errorDescription, errorDescription.contains(ErrorDescription.otpLimitExceed),
               let retrySeconds = response.retryAfterSeconds {
                return .otpResendLimitExceeded(seconds: retrySeconds)
            }
        }
        return nil
    }
    
    static let errorsWhenOTPCancelled = [
        MSBAuthenticationJourney.Error.otpMaxAttemptsReached,
        .userDisabled,
        .userTemporarilyDisabled,
        .incompleteEnrollment,
        .registrationTimeOut,
        .userBlocked
    ]
}

internal extension AuthenticateHeaderResponseParser {
    var otpError: MSBAuthenticationJourney.Error? {
        switch errorCode {
        case 1027:
            return .userTemporarilyDisabled
        case 1028:
            return .userBlocked
        default:
            break
        }
        return nil
    }
}
