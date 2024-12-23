//
//  SessionState+Extensions.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import Backbase

internal extension SessionState {
    var session: Session {
        switch self {
        case .valid:
            return .valid
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
}
