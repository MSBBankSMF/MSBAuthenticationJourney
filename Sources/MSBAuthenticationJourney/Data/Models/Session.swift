//
//  Session.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//

public enum Session {
    /// There is no session at the moment.
    case none
    /// There is at least one valid session at the moment.
    case valid
    /// The current session expired.
    case expired
    /// The account was locked.
    case locked
}
