//
//  Configuration.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 11/11/24.
//

import Foundation
import Resolver
import Backbase
import BackbaseIdentity
import MSBLogger
import MSBUtilities
import Moya

extension MSBAuthenticationJourney {
    public struct Configuration {
        /// Create a new Configuration object with default values
        public init() {
        }
        
        @MainActor public func register() {
            setupBackbaseSDK()
            setupService()
            setupRouters()
        }
    }
}

extension MSBAuthenticationJourney.Configuration {
    @MainActor
    func setupService() {
        let openIdConnectService: OpenIdConnectService = {
            guard let config = Resolver.optional(MSBBackbaseConfiguration.self),
                  let authPlugin = Resolver.optional(AccessTokenPlugin.self) else {
                fatalError("Backbase Config not found")
            }
            let moyaProvider: MoyaProvider<OpenIdConnectService.Target> = {
                return .init(
                    session: .init(configuration: config.securitySessionConfiguration),
                    plugins: [authPlugin]
                )
            }()
            
            return OpenIdConnectService(
                baseURL: config.baseURL,
                moyaProvider: moyaProvider
            )
        }()

        let usecase =  MSBAuthenticationUseCaseImp(
            repository: AuthenticationRepository(remoteDataSource: openIdConnectService)
        )
        Backbase.register(authClient: usecase)
        Resolver.register { usecase as MSBAuthenticationUseCase }
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
    
    private func setupRouters() {
        Resolver.register { BaseRouter() as BBIDRouter }.scope(Resolver.application)
        Resolver.register { BiometricRouter() as BBIDBiometricsRouter }.scope(Resolver.application)
        Resolver.register { PasscodeRouter() as BBIDPasscodeRouter }.scope(Resolver.application)
    }
    
    private var getBBConfigUrl: URL? {
        var configJsonName = "bb_config_production"
        switch EnvironmentValues.environmentType {
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
