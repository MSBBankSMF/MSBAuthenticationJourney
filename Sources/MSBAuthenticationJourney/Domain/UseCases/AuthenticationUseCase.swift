//
//  AuthenticationUseCase.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//
import Foundation

public protocol AuthenticationUseCase {
    func login(userName: String , password: String) throws
    func logout() throws
}
