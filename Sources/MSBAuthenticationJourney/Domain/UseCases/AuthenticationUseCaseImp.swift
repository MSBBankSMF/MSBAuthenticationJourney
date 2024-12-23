//
//  AccountsListUseCaseImp.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//

import Foundation

public final class MSBAuthenticationUseCaseImp: MSBAuthenticationUseCase {
    private let repository: AuthenticationRepositoryProtocol

    // MARK: - Init
    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }
   
    public func login(userName: String, password: String) async throws {
        try await repository.login(userName: userName, password: password)
    }
    
    public func logout() async throws {
        try await repository.logout()
    }
}

