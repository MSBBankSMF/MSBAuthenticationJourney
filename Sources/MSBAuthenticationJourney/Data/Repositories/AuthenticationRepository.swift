//
//  AuthenticationRepository.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 11/11/24.
//
import Combine

public class AuthenticationRepository: AuthenticationRepositoryProtocol {

    private let remoteDataSource: AuthenticationRemoteDataSource
    
    public init(remoteDataSource: AuthenticationRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    public func fetchName() -> Future<String, MSBAuthenticationJourney.Error> {
        remoteDataSource.fetchName()
    }
}
