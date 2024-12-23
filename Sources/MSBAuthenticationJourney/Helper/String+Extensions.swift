//
//  String+Extensions.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import Foundation
import MSBLogger

extension String {
    
    /// String literal of `"invalid_credentials"`
    static let invalidCredentials = "invalid_credentials"
    /// String literal of `"user_temporarily_disabled"`
    static let userTemporarilyDisabled = "user_temporarily_disabled"
    /// String literal of `"user_is_temporarily_disabled"`
    static let userIsTemporarilyDisabled = "user_is_temporarily_disabled"
    /// String literal of `"user_disabled"`
    static let userDisabled = "user_disabled"
    /// String literal of `"user_is_disabled"`
    static let userIsDisabled = "user_is_disabled"
}

public extension String {
    
    /// Decodes value of the JSON in a `String` into a designated BO, or returns `nil` if the decoder fails.
     func decodeBody<T: Codable>() -> T? {
        
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch  {
            MSBLogger().debug("Cannot be decoded as `\(T.self) because \(error).")
            return nil
        }
    }
    
    func split(with: Character, exception: Character? = nil) -> [String] {
        var skip = false
        return split { character in
            if let exception = exception,
               character == exception {
                skip = !skip
            }
            return character == with && !skip
        }.map(String.init)
        .map{
            if let exception = exception {
                return $0.trimmingCharacters(in: CharacterSet(charactersIn: String(exception)))
            }
            return $0
        }
    }
    
    var jsonRepresentation: [String: String]? {
        guard  let jsonData = data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: jsonData,
                                                 options: .allowFragments) as? [String: String]
    }
}
