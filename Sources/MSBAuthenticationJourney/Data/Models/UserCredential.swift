//
//  Credentials.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 25/12/24.
//

// An object representing user's credentials.
public struct UserCredential: Equatable {
    /// Username.
    public let username: String
    /// Password.
    public let password: String

    /// Create a new `User` instance.
    /// - Parameters:
    ///   - username: User's username.
    ///   - password: User's password.
    public init(username: String, password: String) {
        self.username = username.trimmingCharacters(in: .whitespaces)
        self.password = password
    }
    
    internal var isValid: Bool { !username.isEmpty && !password.isEmpty }
}
