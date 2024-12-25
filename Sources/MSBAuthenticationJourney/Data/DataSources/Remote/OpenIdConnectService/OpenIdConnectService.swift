//
//  OpenIdConnectService.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//
import Foundation
import Moya
import MSBNetworking
import Backbase
import BackbaseIdentity
import Combine
import Resolver

public class OpenIdConnectService: AuthenticationRemoteDataSource {
    public typealias Target = OpenIdConnectTargetBuilder
    
    public let moyaProvider: MoyaProvider<Target>
    private let baseURL: URL
  
    public init(
        baseURL: URL,
        moyaProvider: MoyaProvider<Target>
    ) {
        self.moyaProvider = moyaProvider
        self.baseURL = baseURL
    }
    
    public func fetchName() -> Future<String, MSBAuthenticationJourney.Error> {
        return Future<String, MSBAuthenticationJourney.Error> { [weak self] promise in
            guard let self else {
                fatalError("Invalid api call")
                return
            }
            let parameters: [String: Any] = [:] // Add any necessary parameters here
            let target = OpenIdConnectTargetBuilder(operation: .fetchName,
                                                    baseURL: baseURL)
            
            self.moyaProvider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        struct UserInfo: Decodable {
                            let name: String
                        }
                        
                        let userInfo = try JSONDecoder().decode(UserInfo.self, from: response.data)
                        promise(.success(userInfo.name))
                    } catch {
                        Backbase.logWarning(self, message: "Error Decoding User Info Object")
                        promise(.failure(MSBAuthenticationJourney.Error(sdk: error)))
                    }
                    
                case .failure(let error):
                    Backbase.logWarning(self, message: "Network Request Failed")
                    promise(.failure(MSBAuthenticationJourney.Error(sdk: error)))
                }
            }
        }
    }
}
