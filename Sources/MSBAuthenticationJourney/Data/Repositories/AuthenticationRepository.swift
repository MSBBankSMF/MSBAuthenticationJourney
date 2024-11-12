//
//  AuthenticationRepository.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 11/11/24.
//

public class AuthenticationRepository: AuthenticationRepositoryProtocol {
    private let remoteDataSource: AuthenticationRemoteDataSource
    
    public init(remoteDataSource: AuthenticationRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func login(userName: String , password: String) throws {
        try remoteDataSource.login(userName: userName, password: password)
    }
    
    public func logout() throws {
        try remoteDataSource.logout()
    }
}
