//
//  AuthenticationRemoteDataSource.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//

public protocol AuthenticationRemoteDataSource {
    func login(userName: String , password: String) throws
    func logout() throws
}
