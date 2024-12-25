//
//  Error+Passcode+Init.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 26/12/24.
//
import Foundation
import MSBLogger
import Backbase
import BackbaseIdentity

internal extension MSBAuthenticationJourney.Error {
    init(passcode error: Error) {
        defer {
            MSBAuthenticationJourney.Error.logError(self)
        }

        let nsError = error as NSError
        let violatedRulesKey = "violatedRules"
        if let userInfo = nsError.userInfo[NSLocalizedDescriptionKey] as? [String: Any],
           let violatedRules = userInfo[violatedRulesKey],
           let violatedRulesData = try? JSONSerialization.data(withJSONObject: [violatedRulesKey: violatedRules], options: []),
           let error = MSBAuthenticationJourney.Error.isPasscodeRuleViolatedError(data: violatedRulesData) {
            self = error
            return
        }
        
        if let authError = nsError.authenticationError {
            self = authError
            return
        }
        if nsError.description.contains("invalid_token") {
            self = .sessionExpired
            return
        }

        if nsError.description.contains("User aborted authenticator") {
            self = .forceAborted
            return
        }

        let authError = MSBAuthenticationJourney.Error(sdk: error)
        if authError == .invalidCredentials {
            self = .invalidPasscode
        } else {
            if let fidoError = Self.fidoError(error) {
                self = fidoError
                return
            }
            
            switch nsError.code {
            case 400:
                if let data = (nsError.userInfo[NSLocalizedDescriptionKey] as? String)?.data(using: .utf8) {
                    if let error = MSBAuthenticationJourney.Error.isPasscodeRuleViolatedError(data: data) {
                        self = error
                        return
                    } else if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                            jsonObject["error_code"] as? String == "1012",
                            let attempts = jsonObject["attemptsRemaining"] as? Int {
                        self = .invalidPasscodeAttempt(attemptsLeft: attempts)
                        return
                    }
                }
            case BBIDErrors.errorPasscodeMismatch.rawValue:
                self = .passcodeMismatch
                return
            case 1006:
                if nsError.localizedDescription == "Error validating required fields: old and new passcode must not be the same" {
                    self = .newPasscodeSameAsOld
                    return
                }
            case 1011:
                self = .fidoRequestExpired
                return
            case 1012:
                self = .invalidPasscode
                return
            case 1027:
                self = .userTemporarilyDisabled
                return
            case 1028, 1015:
                self = .userBlocked
                return
            default:
                break
            }
            
            // With PSD 2 implementation I-MSDK will not send errorCode in Error.code when there are more than 2 properties in response
            // As BE  changes Device level bruteforce response it has to create new `error` object with the `error_code`,
            // and send to sdk error to identify the correct error.
            // The piece of code will verify if the error has error code then creates new error object with code and checks for Authentication error.
            if let jsonUserInfo = nsError.jsonUserInfo(forKey: NSLocalizedDescriptionKey),
               let errorCode = jsonUserInfo[MSBAuthenticationJourney.Error.Keys.errorCode] as? String,
               let errorCodeInt = Int(errorCode) {
                let error = NSError(domain: BBIDErrorDomain, code: errorCodeInt, userInfo: nsError.userInfo)
                self = MSBAuthenticationJourney.Error(sdk: error)
                return
            }
            self = authError
        }
    }
    
    init(forgotPasscode error: Error) {
        defer {
            MSBAuthenticationJourney.Error.logError(self)
        }
        let authError = MSBAuthenticationJourney.Error(sdk: error)
        if authError  == .invalidCredentials {
            self = .invalidCredentials
            return
        }
        self = MSBAuthenticationJourney.Error(passcode: error)
    }
    
    private static func isPasscodeRuleViolatedError(data: Data) -> MSBAuthenticationJourney.Error? {
        struct ViolatedRules: Codable {
            let violatedRules: [ViolatedRule]
            struct ViolatedRule: Codable {
                let rule: String
            }
        }
        
        if let rules = try? JSONDecoder().decode(ViolatedRules.self, from: data) {
            switch rules.violatedRules.first?.rule {
            case "MUST_NOT_CONTAIN_REPEATING_DIGITS":
                return .passcodeTooManyRepeatingNumbers
            case "MUST_NOT_CONTAIN_SEQUENTIAL_DIGITS":
                return .passcodeTooManyConsecutiveNumbers
            default:
                break
            }
        }
        return nil
    }

}
