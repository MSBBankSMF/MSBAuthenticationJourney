//
//  AccountsListUseCaseImp.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//

import Foundation

public final class AuthenticationUseCaseImp: AuthenticationUseCase {
    private let repository: AuthenticationRepositoryProtocol

    // MARK: - Init
    public init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }
        
    public func login(userName: String, password: String) throws {
        try repository.login(userName: userName, password: password)
    }
    
    public func logout() throws {
        try repository.logout()
    }
}

