//
//  Error.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//
import Foundation
import BackbaseIdentity

public extension MSBAuthenticationJourney {
    /// Authentication journey errors.
    enum Error: Swift.Error {
        /// the device has no internet connection.
        case notConnected
        /// an error occurred relating to the network.
        case networkFailure
        /// The entered credentials are wrong.
        case invalidCredentials
        /// The entered passcode is wrong.
        case invalidPasscode
        /// Session expired.
        case sessionExpired
        /// Account is locked. Registration flow should be restarted.
        case accountLocked
        /// The operation was cancelled by user.
        case cancelledByUser
        /// The registration flow timed out, or was interrupted.
        case incompleteEnrollment
        /// The entered passcodes do not match.
        case passcodeMismatch
        /// Registration timeout
        case registrationTimeOut
        /// The entered passcode have too many repeating numbers
        case passcodeTooManyRepeatingNumbers
        /// The entered passcode have too many consecutive numbers
        case passcodeTooManyConsecutiveNumbers
        /// The entered passcode have custom rules errors
        case passcodeCustomRules([String: String])
        /// The new entered passcode must not be the same as old
        case newPasscodeSameAsOld
        /// Biometric sensor usage was denied by user or system.
        case biometricUsageDenied
        /// Biometric sensor was locked out by the system.
        case biometricLockout
        /// Invalid email format.
        case invalidEmail
        /// Invalid OTP code for forgot password.
        case invalidForgotPasswordOTPCode
        /// OOB transaction signing confirmation is not pending
        case confirmationIsNotPending
        /// OOB transaction signing confirmation failed
        case confirmationFailed
        /// OOB transaction signing confirmation failed due to the session expiring
        case confirmationFailedExpiredSession
        /// OOB transaction signing confirmation failed due to no FIDO authenticators registered
        case confirmationFailedNoAuthenticators
        /// OOB transaction signing confirmation was declined by the user
        case confirmationUserDeclined
        /// biometrics key invalidated.
        case biometricsInvalidated
        /// biometric authentication failed after 3 attempts
        case biometricsAuthenticationFailed
        /// OOB transaction signing confirmation not found
        case confirmationNotFound
        /// Account disabled, user should contact for assistance
        case userDisabled
        /// User blocked, user should contact for assistance, for TS, OOB it should land back to login screen
        /// Blocked according to PSD2 requirements
        case userBlocked
        /// User reached the maximum number of failed authentication attempts
        case userTemporarilyDisabled
        /// User should re-enable device via portal
        case deviceSuspended
        /// User device was removed from portal
        case deviceDoesNotExist
        /// Out-of-band Authentication Confirmation is not pending
        case oobAuthConfirmationIsNotPending
        /// Out-of-band Authentication Confirmation failed
        case oobAuthConfirmationFailed
        /// Out-of-band Authentication Confirmation failed due to no FIDO authenticators registered
        case oobAuthConfirmationFailedNoAuthenticator
        /// Out-of-band Authentication Confirmation was declined by the user
        case oobAuthConfirmationUserDeclined
        /// Out-of-band Authentication confirmation not found
        case oobAuthConfirmationNotFound
        /// Out-of-band Authentication confirmation secret expired
        case oobAuthConfirmationOutdatedSecret
        /// No policies were satisfied
        case noPoliciesWereSatisfied
        /// OTP method selection failed
        case otpMethodSelectionFailed
        /// OTP Max number of attempts reached
        case otpMaxAttemptsReached
        /// Invalid OTP Entered
        case otpAuthIncorrectOTP
        /// Expired OTP Entered
        case otpAuthExpiredOTP
        /// OTP Resend limit exceeded
        case otpResendLimitExceeded(seconds: Int)
        /// Invalid password: minimum length
        case invalidPasswordMinLengthMessage(count: Int)
        /// Invalid password: maximum length
        case invalidPasswordMaxLengthMessage(count: Int)
        /// Invalid password: must contain at least {0} lower case characters.
        case invalidPasswordMinLowerCaseCharsMessage(count: Int)
        /// Invalid password: must contain at least {0} numerical digits.
        case invalidPasswordMinDigitsMessage(count: Int)
        /// Invalid password: must contain at least {0} upper case characters.
        case invalidPasswordMinUpperCaseCharsMessage(count: Int)
        /// Invalid password: must contain at least {0} special characters.
        case invalidPasswordMinSpecialCharsMessage(count: Int)
        /// Invalid password: must not be equal to the username.
        case invalidPasswordNotUsernameMessage
        /// Invalid password: must not be equal to the email.
        case invalidPasswordNotEmailMessage
        /// Invalid password: fails to match regex pattern(s).
        case invalidPasswordRegexPatternMessage
        /// Invalid password: must not be equal to any of last {0} passwords.
        case invalidPasswordHistoryMessage
        /// Invalid password: password is in deny list.
        case invalidPasswordDenylistedMessage
        /// Invalid password: new password does not match password policies.
        case invalidPasswordGenericMessage
        /// Token is not active
        case tokenIsNotActive
        /// Unexpected error
        case unexpectedError
        /// FIDO login failed due to invalid credentials (could be device removed from backend)
        case invalidFIDOCredentials
        /// Request timedout due to network issues.
        case requestTimedOut
        /// The entered passcode attempt is wrong.
        case invalidPasscodeAttempt(attemptsLeft: Int)
        /// Forcefully abort the flow
        case forceAborted
        /// OTP Authentication reached resends limit
        case otpResendLimitReached
        /// Fido request expired
        case fidoRequestExpired
        /// No valid OTP channel
        case noValidOTPChannel
        /// Unknown error thrown by Identity SDK.
        case sdk(Swift.Error)
    }
}

extension MSBAuthenticationJourney.Error: Equatable {
    public static func == (lhs: MSBAuthenticationJourney.Error, rhs: MSBAuthenticationJourney.Error) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}

extension MSBAuthenticationJourney.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Make sure your device is connected to the internet."
        case .networkFailure:
            return "There was a problem with your network."
        case .invalidCredentials:
            return "Incorrect username or password. Try again."
        case .invalidPasscode:
            return "Incorrect passcode. Try again."
        case .sessionExpired:
            return "Session expired. Log in and try again."
        case .accountLocked:
            return "Device locked, restart the authentication flow."
        case .cancelledByUser:
            return "Authentication was cancelled by user."
        case .incompleteEnrollment:
            return "Enrolment was not completed correctly. Please try again."
        case .passcodeMismatch:
            return "Passcodes do not match. Try again."
        case .passcodeTooManyRepeatingNumbers:
            return "The entered passcode have too many repeating numbers"
        case .passcodeTooManyConsecutiveNumbers:
            return "The entered passcode have too many consecutive numbers"
        case .passcodeCustomRules(let errors):
            let errorMessage = errors
                .map { "\($0.key): \($0.value)" }
                .joined(separator: "\n")
            return "The entered passcode have custom rules errors: \n \(errorMessage)"
        case .biometricUsageDenied:
            return "Biometric usage denied. Fix this from Settings and try again."
        case .biometricLockout:
            return "Biometric sensor was locked out due to several wrong attempts." +
                "Lock the device, unlock it with passcode and try again."
        case .invalidEmail:
            return "Invalid email format"
        case .registrationTimeOut:
            return "Registration timeout"
        case .biometricsInvalidated:
            return "Biometrics invalidated. Re-register biometrics and try again."
        case .biometricsAuthenticationFailed:
            return "Biometric authentication failed. Try again"
        case .userDisabled:
            return "Your account has been locked"
        case .userBlocked:
            return "Your account has been locked"
        case .userTemporarilyDisabled:
            return "Your account has been temporarily locked"
        case .deviceSuspended:
            return "This device has been suspended"
        case .deviceDoesNotExist:
            return "Device with given ID does not exist"
        case .confirmationIsNotPending:
            return "Confirmation is not pending."
        case .confirmationFailed:
            return "Confirmation failed."
        case .confirmationFailedExpiredSession:
            return "Confirmation failed (expired session)"
        case .confirmationFailedNoAuthenticators:
            return "Confirmation failed (no authenticators)."
        case .confirmationUserDeclined:
            return "Confirmation user declined."
        case .confirmationNotFound:
            return "Confirmation not found"
        case .oobAuthConfirmationIsNotPending:
            return "Confirmation is not pending."
        case .oobAuthConfirmationFailed:
            return "Confirmation failed"
        case .oobAuthConfirmationFailedNoAuthenticator:
            return "Confirmation failed (no authenticators)."
        case .oobAuthConfirmationUserDeclined:
            return "Confirmation user declined"
        case .oobAuthConfirmationNotFound:
            return "Confirmation not found"
        case .oobAuthConfirmationOutdatedSecret:
            return "Confirmation secret expired"
        case .noPoliciesWereSatisfied:
            return "No policies were satisfied"
        case .otpMethodSelectionFailed:
            return "OTP Method selection failed"
        case .sdk(let error):
            return error.localizedDescription
        case .otpResendLimitExceeded(let seconds):
            return String(format: "Otp resend limit exceeded, try again in %d seconds", seconds)
        case .invalidPasswordMinLengthMessage(let count):
            return "Password must have \(count) characters or more"
        case .invalidPasswordMaxLengthMessage(let count):
            return "Password must have \(count) characters or less"
        case .invalidPasswordMinLowerCaseCharsMessage(let count):
            return "Password must have \(count) lowercase characters"
        case .invalidPasswordMinDigitsMessage(let count):
            return "Password must have \(count) digits"
        case .invalidPasswordMinUpperCaseCharsMessage(let count):
            return "Password must have \(count) uppercase characters"
        case .invalidPasswordMinSpecialCharsMessage(let count):
            return "Password must contain at least \(count) special characters"
        case .invalidPasswordNotUsernameMessage:
            return "Password cannot be the same as your username"
        case .invalidPasswordNotEmailMessage:
            return "Password cannot be your email"
        case .invalidPasswordRegexPatternMessage:
            return "Invalid password"
        case .invalidPasswordHistoryMessage:
            return "Password cannot be a previously used password"
        case .invalidPasswordDenylistedMessage:
            return "Invalid password"
        case .invalidPasswordGenericMessage:
            return "Password does not match the password policy"
        case .otpAuthIncorrectOTP:
            return "Invalid code. Please try again"
        case .otpMaxAttemptsReached:
            return "You don't have any OTP input attempts left. Please restart and try again"
        case .invalidForgotPasswordOTPCode:
            return "Invalid code"
        case .tokenIsNotActive:
            return "Could not verify the action token: Token is not active"
        case .newPasscodeSameAsOld:
            return "Error validating required fields: old and new passcode must not be the same"
        case .unexpectedError:
            return "We were unable to process that request. Please try again"
        case .invalidFIDOCredentials:
            return "This device is not linked to your account"
        case .requestTimedOut:
            return "We were unable to process that request. Please try again."
        case .invalidPasscodeAttempt(let attemptsLeft):
            return "Incorrect passcode. You have \(attemptsLeft) remaining attempts"
        case .forceAborted:
            return "Forcefully abort the flow"
        case .otpAuthExpiredOTP:
            return "Expired code. Please resend and try again"
        case .fidoRequestExpired:
            return "FIDO request expired"
        case .otpResendLimitReached:
            return String(format: "Otp resend limit exceeded")
        case .noValidOTPChannel:
            return "No valid OTP channel"
        }
    }
}

internal extension MSBAuthenticationJourney.Error {
    init(auth error: Error) {
        let localNsError = (error as NSError)

        if let recognisedError = Self.recogniseStatefulFlowError(localNsError) {
            
            self = recognisedError
            return
        } else if let nsError = (error as NSError).rootCause() as? NSError,
           let headerParser = nsError.authenticateParser,
           let errorDescription = headerParser.errorDescription, errorDescription.contains(ErrorDescription.otpLimitExceed),
           let retrySeconds = headerParser.retryAfterSeconds {
            
            self = .otpResendLimitExceeded(seconds: retrySeconds)
            return
        }
        
        self.init(sdk: error)
    }
}

internal extension MSBAuthenticationJourney.Error {
    
    /// Checks whther it is any of thew new errors coming through via stateful flows.
    /// - Parameter nsError: The original error
    /// - Returns: The parsed `Authentication.Error` or `nil`
    static func recogniseStatefulFlowError(_ nsError: NSError) -> MSBAuthenticationJourney.Error? {

        if nsError.isInvalidCredentials.isIt {
            
            return .invalidCredentials
        } else if nsError.isUserPermanentlyDisabled {
            
            return .userDisabled
        } else if nsError.isUserTemporarilyDisabled {

            return .userTemporarilyDisabled
        } else if nsError.isNoValidOTPChannel {

            return .noValidOTPChannel
        } else {
            
            return nil
        }
    }
}

extension MSBAuthenticationJourney.Error {
    struct Keys {
        static let error = "error"
        static let errorCode = "error_code"
        static let errorDescription = "error_description"
        static let errorType = "error_type"
    }
    
    static var Key: String {
        return "AuthJourneyErrorKey"
    }
}
