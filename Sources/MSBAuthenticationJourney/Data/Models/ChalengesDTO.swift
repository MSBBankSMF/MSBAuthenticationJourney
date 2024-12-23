//
//  ChalengesDTO.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//
import Foundation

public struct ChallengesDTO: Sendable, Decodable {
    public let challenges: [ChallengeDTO]
}
