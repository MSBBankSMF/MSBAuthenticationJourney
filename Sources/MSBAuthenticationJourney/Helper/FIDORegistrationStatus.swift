//
//  FIDORegistrationStatus.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 24/12/24.
//
import BackbaseIdentity

protocol FIDORegistrationStatus {
    
    func isBiometricsRegistered(forUsername: String) -> Bool
    func isPasscodeRegistered(forUsername: String) -> Bool
    
    func resetBiometricsRegistration()
    func resetPasscodeRegistration()
}

extension BBIDFIDORegistrationStatus: FIDORegistrationStatus { }
