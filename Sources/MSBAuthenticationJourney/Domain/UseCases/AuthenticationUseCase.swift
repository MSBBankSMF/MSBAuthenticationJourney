//
//  MSBAuthenticationUseCase.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//
import Foundation

public protocol MSBAuthenticationUseCase {
    func login(userName: String , password: String) throws
    func logout() throws
}
