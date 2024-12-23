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

public class OpenIdConnectService: BBIDAuthClient {
    public typealias Target = OpenIdConnectTargetBuilder
    
    public let moyaProvider: MoyaProvider<Target>
    private let baseURL: URL
    
    // used to keep a reference to sdk delegates proxies
    internal var proxies: [String: NSObject] = [:]
    
    /// Last known session state.
    public private(set) var sessionSubject = PassthroughSubject<Session, Never>()
    public var sessionPublisher: AnyPublisher<Session, Never> {
        sessionSubject.eraseToAnyPublisher()
    }
    public var isUserRegistered: Bool = false
    
    // MARK: - Encrypted username storage
    private lazy var storedUserName: Storage = {
        var stored = Storage(key: "com.msb.authentication.username")
        if stored.value == nil {
            stored.value = getOldKeyStoredUsername()
        }
        return stored
    }()
    
    // MARK: - Encrypted name storage
    private lazy var storedName = Storage(key: "com.msb.authentication.name")
    
    public init(
        clientSecret: String? = nil,
        baseURL: URL,
        moyaProvider: MoyaProvider<Target>
    ) {
        self.moyaProvider = moyaProvider
        self.baseURL = baseURL
        super.init(clientSecret: clientSecret)
        Resolver.register { self as OpenIdConnectService }.scope(Resolver.application)
    }
}

extension OpenIdConnectService: AuthenticationRemoteDataSource {
    /// Get username from old key storage key and clear if exists
    private func getOldKeyStoredUsername() -> String? {
        var oldNameStorage = Storage(key: "username")
        let value = oldNameStorage.value
        oldNameStorage.value = nil
        return value
    }
    
    public func logout() async throws {
        
    }
    
    public func login(userName: String , password: String) -> Future<[String: String], MSBAuthenticationJourney.Error> {
        return Future { [weak self] promise in
            // Store the username immediately instead of after authentication so it won't go to the wrong flow when required actions presented
            // IDMOB-1339
            self?.storedUserName.value = userName
            let proxy = PasswordAuthClientResumingDelegateProxy.create(
                handler: { result in
                    promise(result.mapError(MSBAuthenticationJourney.Error.init(auth:)))
                },
                resumingHandler: nil
            )
            self?.proxies["authenticate"] = proxy
            self?.authenticate(withUserId: userName,
                               credentials: password,
                               headers: nil,
                               additionalBodyParameters: nil,
                               tokenNames: [],
                               delegate: proxy)
        }
    }
    
    private func deviceKeyRequest(userName: String, password: String) async throws -> ChallengeDTO {
        let target = Target(
            operation: .requestChallenge(parameters: [
                "grant_type": "password",
                "username": userName,
                "password": password,
            ]),
            baseURL: baseURL
        )
        
        let result: ChallengeDTO = try await moyaProvider.performRequest(target: target)
        return result
    }
    
    /// Check session validity.
    /// - Parameter callback: an optional callback that will be called after the operation finishes.
    public func validateSession() {
        let proxy = AuthClientDelegateProxy { [weak self] state in
            let session = state.session
            //                    self?.sessionChangeHandler?(session)
            if session == .valid && self?.storedName.value == nil {
                self?.fetchName()
                /// If user has registered update the value again
                self?.isUserRegistered = self?.isDeviceRegistered() ?? false
            }
            self?.sessionSubject.send(session)
        }
        proxies["validateSession"] = proxy
        checkSessionValidity(proxy)
    }
    
    /// Fetch users name
    internal func fetchName(completion: ((_ name: String?, _ error: MSBAuthenticationJourney.Error?) -> Void)? = nil) {
        var urlString = Backbase.configuration().backbase.identity.baseURL
        if urlString.last != "/" {
            urlString += "/"
        }
        
        let realm = Backbase.configuration().backbase.identity.realm
        urlString += "auth/realms/\(realm)/protocol/openid-connect/userinfo"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        struct UserInfo: Decodable {
            let name: String
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let bodyData = data,
                  let userInfo = try? JSONDecoder().decode(UserInfo.self, from: bodyData) else {
                Backbase.logWarning(self, message: "Error Decoding User Info Object")
                var authError: MSBAuthenticationJourney.Error?
                if let error = error {
                    authError = MSBAuthenticationJourney.Error(sdk: error)
                }
                completion?(nil, authError)
                return
            }
            
            self.storedName.value = userInfo.name
            completion?(userInfo.name, nil)
        }
        
        task.resume()
    }
}
