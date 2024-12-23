//
//  Error+Init.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import BackbaseIdentity
import LocalAuthentication
import AppAuth
import Resolver
import MSBLogger

internal extension MSBAuthenticationJourney.Error {
    
    // MARK: - Biometric errors
    init(biometric error: Error, biometryType: BiometryType = .allowed) {
        defer {
            MSBAuthenticationJourney.Error.logError(self)
        }
        
        let authError = MSBAuthenticationJourney.Error(sdk: error)
        if authError == .cancelledByUser {
            self = authError
            return
        }
        
        if let fidoError = Self.fidoError(error) {
            self = fidoError
            return
        }
        
        switch biometryType {
        case .denied:
            self = .biometricUsageDenied
        case .lockedOut:
            self = .biometricLockout
        default:
            self = authError
        }
    }
    
    // MARK: - SDK errors
    init(sdk error: Error) {
        self.init(sdk: error, logError: true)
    }
    
    // Check for Auth Error in Rootcause error
    private static func validateRootcauseError(error: NSError) -> MSBAuthenticationJourney.Error? {
        
        let rootCause = error.rootCause()
        
        if let authError = rootCause as? MSBAuthenticationJourney.Error {
            
            return authError
        } else if let nsError = rootCause as? NSError {
            
            if nsError.domain == kCFErrorDomainCFNetwork as String {
                if nsError.code == NSURLErrorNotConnectedToInternet ||
                    nsError.code == NSURLErrorDataNotAllowed {
                    
                    return .notConnected
                } else if nsError.code < 0 {
                    
                    return .networkFailure
                }
            } else if nsError.domain == BBIDErrorDomain,
                      BBIDErrors(rawValue: nsError.code) == .errorForceAborted {
                
                return .forceAborted
            } else if let error = nsError.authenticationError {
                
                return error
            } else if [BBIDErrors.errorUserCancelledRouter.rawValue,
                       BBIDErrors.errorUserDeniedUsage.rawValue,
                       LAError.userCancel.rawValue].contains(nsError.code) {
                
                return .cancelledByUser
            }
        }
        return nil
    }

    // MARK: Private
    private init(sdk error: Error, logError: Bool = false) {
        if let authError = error as? MSBAuthenticationJourney.Error {
            self = authError
            return
        }
        if logError {
            MSBAuthenticationJourney.Error.logError(error)
        }

        let nsError = error as NSError
        
        if let authError = Self.validateRootcauseError(error: nsError) {
            self = authError
            return
        }

        if let headerParser = nsError.authenticateParser,
           ["device-registration", "device-key"].contains(headerParser.challengeType) {

            self = .incompleteEnrollment
            return
        }

        if nsError.domain == LAErrorDomain &&
            nsError.code == LAError.authenticationFailed.rawValue {
            self = .biometricsAuthenticationFailed
            return
        }
        
        if nsError.domain == OIDOAuthAuthorizationErrorDomain,
           nsError.code == OIDErrorCodeOAuth.invalidRequest.rawValue,
           let oAuthUserInfo = nsError.userInfo[OIDOAuthErrorResponseErrorKey] as? [String: String],
           oAuthUserInfo["error_description"] == .invalidCredentials {
            self = .unexpectedError
            return
        }

        self.init(error: error, modifiedError: nsError)
    }
    
    // Checks with error code with modifiedError.
    // Reduces the cyclomatic complexity
    private init(error: Error, modifiedError: NSError) {
        let nsError = modifiedError
        switch nsError.code {
        case 400:
            if let errorDescriptionString = nsError.jsonBody?[MSBAuthenticationJourney.Error.Keys.errorDescription] as? String {
                switch errorDescriptionString {
                case "Device is not enabled":
                    self = .deviceSuspended
                case "User is temporarily disabled": // Temporary error messages
                    self = .userTemporarilyDisabled
                case "User is disabled", "Account disabled":
                    self = .userDisabled
                default:
                    self = .sdk(error)
                }
                return
            }
            self = .sdk(error)

        case 401, 403, 1012:
            if let errorDescriptionString = nsError.jsonBody?[MSBAuthenticationJourney.Error.Keys.error] as? String,
               errorDescriptionString == "User temporarily disabled" { // Temporary error messages
                self = .userTemporarilyDisabled
                return
            }
            self = .invalidCredentials

        case BBIDErrors.errorDeviceKeyNotFound.rawValue,
            BBIDErrors.errorInvalidDeviceId.rawValue,
            1007:
            if nsError.localizedDescription == "Expired action token" {
                self = .registrationTimeOut
            } else {
                self = .incompleteEnrollment
            }
        case 1014:
            if nsError.localizedDescription == "Device with given ID does not exist" {
                self = .deviceDoesNotExist
            } else {
                self = .sdk(error)
            }
        case 1018:
            self = .userTemporarilyDisabled
        case BBIDErrors.errorNoMatchingPolicy.rawValue:
            self = .noPoliciesWereSatisfied
        case BBIDErrors.errorUserCancelledRouter.rawValue,
            BBIDErrors.errorUserDeniedUsage.rawValue,
            LAError.userCancel.rawValue:
            self = .cancelledByUser
        case 1020:
            self = .accountLocked
        case 1021:
            if nsError.localizedDescription == "Device is not enabled" {
                self = .deviceSuspended
            } else {
                self = .sdk(error)
            }
        case 1408:
            if nsError.localizedDescription == "Registration request has expired" ||
                nsError.localizedDescription == "Authentication request has expired" {
                self = .registrationTimeOut
            } else {
                self = .sdk(error)
            }
        case BBIDErrors.biometricsInvalidated.rawValue:
            self = .biometricsInvalidated
        default:
            self = .sdk(error)
        }
    }

    static func logError(_ error: Error) {
        let nsError = error as NSError
        MSBLogger().warning("Authentication Journey received error:\n\(nsError.causeTrace())")
        if let rootCause = nsError.rootCause() as NSError? {
            MSBLogger().debug("Root cause:\n\(rootCause)")
            if let body = rootCause.body {
                MSBLogger().debug("Root cause:\n\(rootCause)")
            }
        }
    }
        
    static func fidoError(_ error: Error) -> MSBAuthenticationJourney.Error? {
        
        let nsError: NSError
        if let authError = error as? MSBAuthenticationJourney.Error,
           case .sdk(let sdkError) = authError {
            nsError = sdkError as NSError
        } else {
            nsError = error as NSError
        }
        if nsError.code == 400,
           let errorDescriptionString = nsError.jsonBody?[MSBAuthenticationJourney.Error.Keys.errorDescription] as? String,
           errorDescriptionString == "Invalid user credentials" {
            return .invalidFIDOCredentials
        }
        
        if nsError.isNetworkConnectionError {
            return .requestTimedOut
        }
        return nil
    }
}
