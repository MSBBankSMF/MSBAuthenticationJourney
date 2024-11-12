//
//  AuthenticationRepositoryProtocol.swift
//
//  Created by doandat on 11/11/24.
//
import Foundation

public protocol AuthenticationRepositoryProtocol {
    func login(userName: String , password: String) throws
    func logout() throws
}

