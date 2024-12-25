//
//  LoginViewModel.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 12/11/24.
//


import Foundation
import Combine
import Resolver
import MSBLogger

public final class LoginViewModel: ObservableObject {
    @Published private(set) var screenState: LoginScreenState = .initial
    @Published var username: String = "sdbxaz-stg-amos"
    @Published var password: String = "fgKiPcSCiKquxGMQ"
    @Published var isFormValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let allowedBiometry: CurrentValueSubject<BiometryType, Never>

    private lazy var authenticationUseCase: MSBAuthenticationUseCase = {
        guard let useCase = Resolver.optional(MSBAuthenticationUseCase.self) else {
            fatalError("AuthenticationUseCase needed to continue")
        }
        return useCase
    }()
    
    var isBiometricSupported: Bool {
        guard authenticationUseCase.isBiometricEnrolled else { return false }
        return [.faceID, .touchID, .lockedOut].contains(allowedBiometry.value)
    }

    var isPasscodeSupported: Bool {
        return authenticationUseCase.isPasscodeEnrolled
    }
    
    var preCompletion: ((UserCredential) -> Void)?
    
    public init(session: Session,
                allowedBiometry: CurrentValueSubject<BiometryType, Never> = CurrentValueSubject(BiometryType.allowed)) {
        self.allowedBiometry = allowedBiometry
        if authenticationUseCase.isEnrolled {
            authenticationUseCase.authenticateWithPasscode()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                    }
                }, receiveValue: { headers in
                    print("Received headers: \(headers)")
                })
                .store(in: &cancellables)
        }
        $username
            .combineLatest($password)
            .map { !$0.isEmpty && !$1.isEmpty }
            .assign(to: &$isFormValid)
    }
    
    private func login(fromEvent event: LoginScreenEvent) async {
        DispatchQueue.main.async {
            self.screenState = .loading
        }
        let userCredential = UserCredential(username: username, password: password)
        var handler: (() -> Void)?
        if let preCompletion = preCompletion {
            handler = {
                DispatchQueue.main.async {
                    preCompletion(userCredential)
                }
            }
        }

        // This is show the Setup complete screen after we receive access token
        let preCompletionHandler = resumeAuthentication(for: userCredential, with: handler)
        
        authenticationUseCase.authenticate(user: userCredential,
                                           shouldValidateSession: false,
                                           preCompletion: preCompletionHandler)
        .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                MSBLogger().debug("resumeAuthentication error \(error)")
            }
        }, receiveValue: { headers in
            
        })
        .store(in: &cancellables)
    }
    
    /// Resume authentication after FIDO auth
    private func resumeAuthentication(for user: UserCredential,
                                      with handler: (() -> Void)?) -> (() -> Void)? {
        return { [weak self] in
            guard let self else { return }
            authenticationUseCase.authenticate(user: user,
                                               shouldValidateSession: false,
                                               preCompletion: nil)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    MSBLogger().debug("resumeAuthentication error \(error)")
                    self?.authenticationUseCase.validateSession()
                }
            }, receiveValue: { headers in
                handler?()
            })
            .store(in: &cancellables)
        }
    }
    
    func onEvent(_ event: LoginScreenEvent) {
        switch event {
        case .login:
            Task {
                await login(fromEvent: event)
            }
        }
    }
}
