//
//  LoginScreenEvent.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 12/11/24.
//

import Foundation

/// All possible events from the AccountsListScreen
public enum LoginScreenEvent {
    /// Load accounts
    case login
}

extension LoginScreenEvent: Equatable {}
