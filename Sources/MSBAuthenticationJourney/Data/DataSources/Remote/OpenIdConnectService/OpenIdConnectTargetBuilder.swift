//
//  OpenIdConnectTargetBuilder.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//
import Foundation
import Backbase
import Moya

public struct OpenIdConnectTargetBuilder: TargetType, AccessTokenAuthorizable {
    let operation: OperationType
    
    public var baseURL: URL
    public var path: String {
        switch operation {
        case .fetchName:
            return "/auth/\(Backbase.configuration().backbase.identity.realm)/protocol/openid-connect/userinfo"
        }
    }
    
    public var method: Moya.Method {
        switch operation {
        case .fetchName:
            return .get
        }
    }
    
    public var task: Task {
        switch operation {
        case .fetchName:
            return .requestPlain
            
        }
    }
    
    public var validationType: ValidationType {
        .none
    }
    
    public var authorizationType: AuthorizationType? {
        switch operation {
        case .fetchName:
            return .basic
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
}

extension OpenIdConnectTargetBuilder {
    enum OperationType {
        case fetchName
    }
}

