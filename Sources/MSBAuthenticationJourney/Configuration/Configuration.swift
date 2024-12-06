//
//  Configuration.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 11/11/24.
//

import Foundation
import Resolver
import Backbase
import MSBLogger
import MSBFoundation
import Moya

extension MSBAuthenticationJourney {
    public struct Configuration {
        /// Create a new Configuration object with default values
        public init() {
        }
        
        public func register() {
            setupBackbaseSDK()
        }
        
        
    }
}

extension MSBAuthenticationJourney.Configuration {
    private func setupBackbaseSDK() {
        guard let destinationFileUrl = self.getBBConfigUrl else {
            fatalError("Config not found")
        }
        MSBLogger().debug("backbase destinationFileUrl: \(destinationFileUrl)")
        do {
            try Backbase.initialize(from: destinationFileUrl, forceDecryption: false)
        } catch {
            MSBLogger().debug("\(error)")
        }
        #if DEBUG
            Backbase.setLogLevel(.debug)
        #endif
        
        
        let baseUrl: URL = {
            guard let serverUrlString = Backbase.configuration().backbase.serverURL,
                    let url = URL(string: serverUrlString) else {
                fatalError("serverURL not found")
            }
            return url
        }()
        let config = MSBBackbaseConfiguration(
            baseURL: baseUrl,
            securitySessionConfiguration: Backbase.securitySessionConfiguration()
        )
        Resolver.register { config }

        let authPlugin = AccessTokenPlugin { _ in
            guard let authorizationHeader = Backbase.authClient().tokens()["Authorization"] else {
                return ""
            }
            return authorizationHeader.replacingOccurrences(of: "Bearer ", with: "")
        }
        Resolver.register { authPlugin }
    }
    
    private var getBBConfigUrl: URL? {
        var configJsonName = "bb_config_production"
        switch MSBEnvironmentValues.environmentType {
        case .dev:
            configJsonName = "bb_config_dev"
        case .sit:
            configJsonName = "bb_config_sit"
        case .uat:
            configJsonName = "bb_config_uat"
        case .pilot:
            configJsonName = "bb_config_pilot"
        default:
            configJsonName = "bb_config_production"
        }
        MSBLogger().debug("\(configJsonName)")
        return Bundle.main.url(forResource: configJsonName, withExtension: "json") ?? Bundle.authenticationJourney?.url(forResource: configJsonName, withExtension: "json")
    }
}
