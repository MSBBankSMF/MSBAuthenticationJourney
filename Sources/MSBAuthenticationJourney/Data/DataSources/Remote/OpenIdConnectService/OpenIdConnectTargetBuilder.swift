//
//  OpenIdConnectTargetBuilder.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//
import Foundation
import Moya

public struct OpenIdConnectTargetBuilder: TargetType, AccessTokenAuthorizable {
    let operation: OperationType
    
    public var baseURL: URL
    public var path: String {
        switch operation {
        case .requestChallenge:
            return "/auth/realms/customer/protocol/openid-connect/token"
        }
    }
    
    public var method: Moya.Method {
        switch operation {
        case .requestChallenge:
            return .post
        }
    }
    
    public var task: Task {
        switch operation {
        case .requestChallenge(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        }
    }
    
    public var validationType: ValidationType {
        .none
    }
    
    public var authorizationType: AuthorizationType? {
        switch operation {
        case .requestChallenge:
            return .basic
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
}

extension OpenIdConnectTargetBuilder {
    enum OperationType {
        case requestChallenge(parameters: [String: Any])
    }
}

