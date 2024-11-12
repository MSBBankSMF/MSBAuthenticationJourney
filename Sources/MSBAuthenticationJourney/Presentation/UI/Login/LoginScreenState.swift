//
//  LoginScreenState.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 12/11/24.
//

import Foundation

public enum LoginScreenState {
    case initial
    /// Loading / searching
    case loading
    /// Idle state
    case authenticated
    /// Error has been encountered
    case hasError
}
