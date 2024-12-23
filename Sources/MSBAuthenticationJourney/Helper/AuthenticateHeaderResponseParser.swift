//
//  AuthenticateHeaderResponseParser.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import Foundation

struct AuthenticateHeaderResponseParser {
    private let parsedData: [String: String]
    
    init(message: String) {
        let trimmedMessage = message.hasPrefix("Bearer ") ?
            message.replacingOccurrences(of: "Bearer ", with: "") :
            message
        let components = trimmedMessage.split(with: ",", exception: "\"")
        var parser: [String: String] = [:]
        components.forEach({ each in
            let subComponents = each.components(separatedBy: "=")
            if subComponents.count == 2 {
                let value = subComponents[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                parser[subComponents[0]] = value
            }
        })
        parsedData = parser
    }
    
    init(jsonMessage: String) {
        parsedData = jsonMessage.jsonRepresentation ?? [:]
    }
}

// MARK: Error Parser
extension AuthenticateHeaderResponseParser {
    var errorType: String? {
        return parsedData[MSBAuthenticationJourney.Error.Keys.errorType] ?? parsedData[MSBAuthenticationJourney.Error.Keys.error]
    }
    
    var errorDescription: String? {
        return parsedData[MSBAuthenticationJourney.Error.Keys.errorDescription]
    }
    
    var errorCode: Int? {
        if let code = parsedData[MSBAuthenticationJourney.Error.Keys.errorCode] {
            return Int(code)
        }
        return nil
    }
    
}

// MARK: Challenge Type
extension AuthenticateHeaderResponseParser {
    var challengeType: String? {
        return parsedData["challenge_types"]
    }
    
}

// MARK: OTP Parser retry seconds
extension AuthenticateHeaderResponseParser {
    var retryAfterSeconds: Int? {
        if errorType == "invalid_grant",
           let errorDescription = errorDescription {
            let words = errorDescription.components(separatedBy: " ")
            if let secondsWord = words.suffix(2).first {
                return Int(secondsWord)
            }
        }
        return nil
    }
}
