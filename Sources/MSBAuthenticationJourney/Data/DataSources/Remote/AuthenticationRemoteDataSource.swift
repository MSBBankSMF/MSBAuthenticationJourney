//
//  AuthenticationRemoteDataSource.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//
import Combine

public protocol AuthenticationRemoteDataSource {
    func login(userName: String , password: String) -> Future<[String: String], MSBAuthenticationJourney.Error>
    func logout() async throws
}
