//
//  BackbaseService.swift
//  EnterpriseBanking
//
//  Created by doandat on 18/11/24.
//

import Backbase
import AppAuth
import BackbaseIdentity
import Foundation
import PluggableAppDelegate
import UIKit
import MSBLogger
import MSBUtilities
import Resolver
import Moya

public final class BackbaseService: NSObject, ApplicationService {
    public override init() {
        super.init()
        MSBLogger().debug("BackbaseService")
        
        setupBackbaseSDK()
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func setupBackbaseSDK() {
        guard let destinationFileUrl = self.getBBConfigUrl else {
            fatalError("Config not found")
        }
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
//            return URL(string: "https://mock.apidog.com/m1/683076-655710-default")!
            
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
        return Bundle.module.url(forResource: configJsonName, withExtension: "json")
    }
}

class MSBSessionHandler: MSBSessionProtocol {
    var logout: () -> Void
    
    var revoke: () -> Void
    
    init(logout: @escaping () -> Void, revoke: @escaping () -> Void) {
        self.logout = logout
        self.revoke = revoke
    }
}
