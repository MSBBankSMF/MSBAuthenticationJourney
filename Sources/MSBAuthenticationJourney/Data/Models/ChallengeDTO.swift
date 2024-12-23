//
//  ChallengeDTO.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//
import Foundation

public struct ChallengeDTO: Sendable, Decodable {
    public let challengeType: String?
    public let nonce: String?
    public let deviceId: String?
}
