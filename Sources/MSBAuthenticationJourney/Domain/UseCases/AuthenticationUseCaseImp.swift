//
//  AccountsListUseCaseImp.swift
//  MSBAccountsJourney
//
//  Created by doandat on 11/11/24.
//
import Backbase
import BackbaseIdentity
import Resolver
import Foundation
import Combine
import MSBLogger
import LocalAuthentication

public final class MSBAuthenticationUseCaseImp: BBIDAuthClient {
    private let repository: AuthenticationRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public var isUserRegistered: Bool = false
    public private(set) var sessionSubject = PassthroughSubject<Session, Never>()
    
    /// Last known session state.
    public private(set) var lastSession: Session?
    
    private lazy var routers = Routers()
    
    // used to keep a reference to sdk delegates proxies
    internal var proxies: [String: NSObject] = [:]
    internal var isDeviceBiometricsEnabled: () -> Bool = {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    internal var fidoRegistrationStatusUseCaseWrapper: FIDORegistrationStatus {
        fidoRegistrationStatus
    }
    
    // MARK: - Init
    public init(clientSecret: String? = nil,
                repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
        super.init(clientSecret: clientSecret)
        isUserRegistered = isDeviceRegistered()
    }
    
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
    
    public override func reset() {
        storedUserName.value = nil
        storedName.value = nil
        isUserRegistered = false
        super.reset()
    }
    
}

extension MSBAuthenticationUseCaseImp {
    /// Get username from old key storage key and clear if exists
    private func getOldKeyStoredUsername() -> String? {
        var oldNameStorage = Storage(key: "username")
        let value = oldNameStorage.value
        oldNameStorage.value = nil
        return value
    }
    
    private func invalidateTokens(with delegate: AuthClientDelegate) {
        let proxy = BBIDAuthClientDelegateProxy { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                MSBLogger().warning("Token was not invalidated: \(error.localizedDescription)")
            }
            self?.endSession(with: delegate, error: nil)
        }
        proxies["invalidateTokensProxy"] = proxy
        invalidateTokens(with: proxy)
    }
}

extension MSBAuthenticationUseCaseImp: MSBAuthenticationUseCase {
    public func authenticate(user: UserCredential, shouldValidateSession: Bool, preCompletion: (() -> Void)?) -> Future<Headers, MSBAuthenticationJourney.Error> {
        return Future { [weak self] promise in
            self?.storedUserName.value = user.username
            let proxy = PasswordAuthClientResumingDelegateProxy.create(
                handler: { result in
                    if (try? result.get()) != nil, shouldValidateSession {
                        self?.validateSession()
                    }
                    promise(result.mapError(MSBAuthenticationJourney.Error.init(auth:)))
                },
                resumingHandler: preCompletion
            )
            self?.proxies["authenticate"] = proxy
            self?.authenticate(withUserId: user.username,
                               credentials: user.password,
                               headers: nil,
                               additionalBodyParameters: nil,
                               tokenNames: [],
                               delegate: proxy)
        }
    }
    
    public func authenticate(user: UserCredential) -> Future<Headers, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
            // store the username
            storedUserName.value = user.username
            
            // create the proxy
            let proxy = PasswordAuthClientResumingDelegateProxy.create(handler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error as NSError) where error.rootError?.code == BBIDErrors.fatalError.rawValue &&
                    error.rootError?.localizedDescription == "flow_ended_successfully":
                    validateSession()
                case .failure(let error as NSError) where error.rootError?.code == BBIDErrors.errorUserCancelledRouter.rawValue &&
                    isDeviceRegistered() == true:
                    promise(.failure(.cancelledByUser))
                    validateSession()
                case .failure(let error):
                    promise(.failure(MSBAuthenticationJourney.Error(auth: error)))
                default:
                    do {
                        let headers = try result.get()
                        promise(.success(headers))
                    } catch {
                        promise(.failure(MSBAuthenticationJourney.Error(auth: error)))
                    }
                }
            })
            
            self.proxies["authenticate"] = proxy
            
            // perform authentication
            self.authenticate(userId: user.username,
                              credentials: user.password,
                              headers: nil,
                              delegate: proxy)
        }
    }
    
    public func authenticateWithBiometrics() -> Future<Headers, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
            guard let username = cachedUsername else { return }
            routers.prepareForBiometric(in: self)
                    let proxy = PasswordAuthClientDelegateProxy(handler: { [weak self] result in
                        guard let self = self else { return }
                        if (try? result.get()) != nil {
                            validateSession()
                        }
                        routers.reRegisterAllFIDO(using: self)
                        promise(result.mapError { MSBAuthenticationJourney.Error(biometric: $0) })
                    })
                    proxies["authenticateWithBiometrics"] = proxy
                    authenticateRegisteredDevice(withUsername: username, headers: nil, delegate: proxy)
                }
    }
    
    public func authenticateWithPasscode() -> Future<Headers, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
            guard let username = cachedUsername else { return }
            routers.prepareForPasscode(in: self)
                    let proxy = PasswordAuthClientDelegateProxy(handler: { [weak self] result in
                        guard let self = self else { return }
                        if (try? result.get()) != nil {
                            self.validateSession()
                        }
                        promise(result.mapError(MSBAuthenticationJourney.Error.init(passcode:)))
                        routers.reRegisterAllFIDO(using: self)
                    })
                    proxies["authenticateWithPasscode"] = proxy
                    authenticateRegisteredDevice(withUsername: username, headers: nil, delegate: proxy)
                }
    }
    
    public func completeRegistration() -> Future<Headers, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
            guard let username = cachedUsername else { return }
                    let proxy = BBIDFIDORegistrationDelegateProxy { promise($0.map { [:] }) }
            proxies["completeRegistration"] = proxy
                    startUAFRegistration(withUsername: username, delegate: proxy)
                }
    }
    
    public func lateEnrollBiometrics() -> Future<MSBAuthenticationJourney.Error?, Never> {
        Future { [weak self] promise in
            guard let self else { return }
                    guard isDeviceBiometricsEnabled() else {
//                        showDeviceBiometricsNotEnabledAlert {
//                            promise(.success(.biometricUsageDenied))
//                        }
                        return
                    }
            guard let username = cachedUsername else { return }
            routers.prepareForBiometric(in: self)
                    let hasEnrolled = isBiometricEnrolled
                    let proxy = BBIDFIDORegistrationDelegateProxy { [weak self, hasEnrolled] result in
                        guard let self = self else { return }
                        switch result {
                        case .success:
                            if !hasEnrolled && isBiometricEnrolled {
//                                lateEnrollBiometric - successScreen - didFinishLateEnrollBiometric {
//                                    promise(.success(nil))
//                                }
                            } else {
                                promise(.success(nil))
                            }
                        case .failure(let error):
                            MSBLogger().warning("Biometrics registration returns error: \(error.localizedDescription)")
                            promise(.success(error))
                        }
                        routers.reRegisterAllFIDO(using: self)
                    }
                    proxies["lateEnrollBiometrics"] = proxy
                    self.startUAFRegistration(withUsername: username, delegate: proxy)
                }
    }
    
    public func changePasscode() -> Future<Void, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
                    guard let username = cachedUsername else { return }
                    let proxy = BBIDPasscodeChangeDelegateProxy { promise($0.mapError(MSBAuthenticationJourney.Error.init(passcode:))) }
                    proxies["changePasscode"] = proxy
                    BBIDPasscodeManager.changePasscode(username, authClient: self, delegate: proxy)
                }
    }
    
    public func forgotUsername() -> Future<Data, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
                    let proxy = BBIDForgottenCredentialsDelegateProxy(usernameHandler: {
                        promise($0)
                    }, passwordHandler: nil)
                    proxies["forgotUsername"] = proxy
                    BBIDForgottenCredentialsManager.retrieveForgottenUsername(proxy)
                }
    }
    
    public func forgotPassword() -> Future<Data, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
                    let proxy = BBIDForgottenCredentialsDelegateProxy(usernameHandler: nil, passwordHandler: {
                        promise($0)
                    })
                    proxies["forgotPassword"] = proxy
                    BBIDForgottenCredentialsManager.retrieveForgottenPassword(proxy)
                }
    }
    
    public func forgotPasscode(user: UserCredential) -> Future<Data, MSBAuthenticationJourney.Error> {
        Future { [weak self] promise in
            guard let self else { return }
                    let proxy = BBIDForgottenCredentialsDelegateProxy(passcodeHandler: {
                        promise($0)
                    })
                    proxies["forgotPasscode"] = proxy
                    BBIDForgottenCredentialsManager.forgotPasscode(username: user.username,
                                                                   password: user.password,
                                                                   delegate: proxy)
                }
    }
    
    @discardableResult
    public func disableBiometrics() -> Bool {
        let biometricRouters = self.routers(ofType: BBIDBiometricsRouter.self)
                if biometricRouters.isEmpty {
                    return false
                }
                fidoRegistrationStatusUseCaseWrapper.resetBiometricsRegistration()
                return true
    }
    
    public func endSession() -> Future<Session, Never> {
        Future { [weak self] promise in
            guard let self else { return }
                    let proxy = AuthClientDelegateProxy { [weak self] state in
                        let session = state.session
                        self?.lastSession = session
                        self?.sessionSubject.send(session)
                        promise(.success(session))
                    }
                    proxies["endSession"] = proxy
                    invalidateTokens(with: proxy)
                }
    }
    
    public func logOut() -> Future<Session, Never> {
        Future { [weak self] promise in
            guard let self else { return }
                    self.reset()
                    let proxy = AuthClientDelegateProxy { [weak self] state in
                        let session = state.session
                        self?.lastSession = session
                        self?.sessionSubject.send(session)
                        promise(.success(session))
                    }
                    proxies["logOut"] = proxy
                    invalidateTokens(with: proxy)
                }
    }
    
    public func expireSession() -> Future<Session, Never> {
        Future { [weak self] promise in
            guard let self else { return }
                    let proxy = AuthClientDelegateProxy { [weak self] _ in
                        self?.lastSession = .expired
                        self?.sessionSubject.send(.expired)
                        promise(.success(.expired))
                    }
                    proxies["expireSession"] = proxy
                    endSession(with: proxy, error: nil)
                }
    }
    
    public func lockAccount() -> Future<Session, Never> {
        Future { [weak self] promise in
            guard let self else { return }
                    reset()
                    let proxy = AuthClientDelegateProxy { [weak self] _ in
                        self?.lastSession = .locked
                        self?.sessionSubject.send(.locked)
                        promise(.success(.locked))
                    }
                    proxies["lockAccount"] = proxy
                    endSession(with: proxy, error: nil)
                }
    }
    
    public func validateSession() {
        let proxy = AuthClientDelegateProxy { [weak self] state in
            let session = state.session
            //                    self?.sessionChangeHandler?(session)
            if session == .valid && self?.cachedName == nil {
                Task {
                    let name = await self?.fetchName()
                    self?.storedName.value = name
                }
                /// If user has registered update the value again
                self?.isUserRegistered = self?.isDeviceRegistered() ?? false
            }
            self?.sessionSubject.send(session)
        }
        proxies["validateSession"] = proxy
        checkSessionValidity(proxy)
    }
    
    public var isEnrolled: Bool {
        isDeviceRegistered() && (isPasscodeEnrolled || isBiometricEnrolled)
    }
    
    public var cachedUsername: String? {
        storedUserName.value
    }
    
    public var cachedName: String? {
        storedName.value
    }
    
    public var isBiometricEnrolled: Bool {
        guard let username = cachedUsername else { return false }
        return fidoRegistrationStatusUseCaseWrapper.isBiometricsRegistered(forUsername: username)
    }
    
    public var isPasscodeEnrolled: Bool {
        guard let username = cachedUsername else { return false }
        return fidoRegistrationStatusUseCaseWrapper.isPasscodeRegistered(forUsername: username)
    }
    
    public func logout() async throws {
        
    }
    
    public func fetchName() async -> String? {
        do {
            return try await repository.fetchName().value
        } catch {
            return nil
            Backbase.logWarning(self, message: "Failed to fetch name: \(error)")
        }
    }
}

