//
//  AuthenticationRepositoryProtocol.swift
//
//  Created by doandat on 11/11/24.
//
import Foundation
import Combine

public protocol AuthenticationRepositoryProtocol {
    func fetchName() -> Future<String, MSBAuthenticationJourney.Error>
}

