//
//  MSBAuthenticationUseCase.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//
import Foundation

public protocol MSBAuthenticationUseCase {
    func login(userName: String , password: String) async throws
    func logout() async throws
}
