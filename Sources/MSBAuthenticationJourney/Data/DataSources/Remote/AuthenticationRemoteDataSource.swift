//
//  AuthenticationRemoteDataSource.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//
import Combine

public protocol AuthenticationRemoteDataSource {
    func fetchName() -> Future<String, MSBAuthenticationJourney.Error>
}
