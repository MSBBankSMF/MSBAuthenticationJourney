//
//  MSBAuthenticationUseCase.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//
import Foundation
import Combine

public protocol MSBAuthenticationUseCase {
    typealias Headers = [String: String]
    /// Starts the ROPC registration flow for a given `User` object, but will not send callback to session listener,
    /// Have to call `validateSession` api manually in post completion to call session listener.
    /// - Parameters:
    ///   - user: user.
    ///   - shouldValidateSession: boolean value, if true it will call `validateSession` after authentication success, defaults to true
    ///   - preCompletion: an optional handler to be called before the flow finishes.
    /// - Returns: A publisher that emits the authentication result.
    func authenticate(user: UserCredential, shouldValidateSession: Bool, preCompletion: (() -> Void)?) -> Future<Headers, MSBAuthenticationJourney.Error>
    
    /// Starts the stateful registration flow for a given `User` object, but will not send callback to session listener,
    /// Have to call `validateSession` api manually in post completion to call session listener.
    /// - Parameters:
    ///   - user: The user
    /// - Returns: A publisher that emits the authentication result.
    func authenticate(user: UserCredential) -> Future<Headers, MSBAuthenticationJourney.Error>
    
    /// Start authentication with biometrics for the authenticated user.
    /// - Returns: A publisher that emits the authentication result.
    func authenticateWithBiometrics() -> Future<Headers, MSBAuthenticationJourney.Error>
    
    /// Start authentication with passcode for the authenticated user.
    /// - Returns: A publisher that emits the authentication result.
    func authenticateWithPasscode() -> Future<Headers, MSBAuthenticationJourney.Error>
    
    /// Start the "complete registration" flow for the authenticated user.
    /// - Returns: A publisher that emits the authentication result.
    func completeRegistration() -> Future<Headers, MSBAuthenticationJourney.Error>
    
    /// Start the "late biometrics enrollment" flow for the authenticated user.
    /// - Returns: A publisher that emits an optional error.
    func lateEnrollBiometrics() -> Future<MSBAuthenticationJourney.Error?, Never>
    
    /// Start the "change passcode" flow for the authenticated user.
    /// - Returns: A publisher that emits the passcode change result.
    func changePasscode() -> Future<Void, MSBAuthenticationJourney.Error>
    
    /// Start the "forgot username" flow for the registered user.
    /// - Returns: A publisher that emits the forgotten credentials result.
    func forgotUsername() -> Future<Data, MSBAuthenticationJourney.Error>
    
    /// Start the "forgot password" flow for the registered user.
    /// - Returns: A publisher that emits the forgotten credentials result.
    func forgotPassword() -> Future<Data, MSBAuthenticationJourney.Error>
    
    /// Start the `forgot passcode` flow for the registered user.
    /// - Parameter user: user
    /// - Returns: A publisher that emits the forgotten credentials result.
    func forgotPasscode(user: UserCredential) -> Future<Data, MSBAuthenticationJourney.Error>
    
    /// Initiate an attempt to disable biometrics
    @discardableResult func disableBiometrics() -> Bool
    
    /// End current session for the authenticated user.
    /// - Returns: A publisher that emits the session.
    func endSession() -> Future<Session, Never>
    
    /// End current session for the authenticated user and reset the authentication flow.
    /// - Returns: A publisher that emits the session.
    func logOut() -> Future<Session, Never>
    
    /// End current session for the authenticated user and set the session state to `Session.expired`.
    /// - Returns: A publisher that emits the session.
    func expireSession() -> Future<Session, Never>
    
    /// End current session for the authenticated user and set the session state to `Session.locked`.
    /// - Returns: A publisher that emits the session.
    func lockAccount() -> Future<Session, Never>
    
    /// Initiates a new custom registration flow that can be managed externally.
    ///
    /// This function generates a unique `flowID` associated with the registration flow type
    /// and caches the provided `username` to be displayed on the UI. It serves as an enabler
    /// for starting a custom registration flow from an external source.
    ///
    /// The returned `flowID` must be included as a header in subsequent registration requests
    /// at the project level. Specifically, the `flowID` should be added to the HTTP request
    /// headers under the key `identity-mobile-flow-id`.
    ///
    /// Example:
    /// ```swift
    /// let flowID = createNewAuthenticationFlow(username: "exampleUser")
    /// request.addValue(flowID.uuidString, forHTTPHeaderField: "identity-mobile-flow-id")
    /// ```
    ///
    /// - Parameter username: The username intended for registration within the flow.
    /// - Returns: A `UUID` representing the unique identifier (`flowID`) for the registration flow.
    ///            This identifier must be added as a header in the registration request.
    func createNewAuthenticationFlow(username: String) -> UUID
    
    /// Notifies the SDK that the external registration flow has been completed.
    ///
    /// This function finalizes the custom registration process by cleaning up any flow-related details
    /// and sensitive information that were stored during the registration process.
    /// It is essential to call this method once the external registration flow is successfully finished to
    /// ensure proper cleanup and avoid potential security risks.
    ///
    /// - Parameter uuid: The `flowID` generated during the custom registration flow, which needs to be cleaned up.
    func finishAuthenticationFlow(flowID uuid: UUID)
    
    /// Check session validity.
    /// - Returns: A publisher that emits the session.
    func validateSession()
    
    var isEnrolled: Bool { get }
    var isBiometricEnrolled: Bool { get }
    var isPasscodeEnrolled: Bool { get }
    var cachedUsername: String? { get }
    var cachedName: String? { get }
}
