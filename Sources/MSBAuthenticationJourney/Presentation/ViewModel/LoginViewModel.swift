//
//  LoginViewModel.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 12/11/24.
//


import Foundation
import Combine
import Resolver

public final class LoginViewModel: ObservableObject {
    @Published private(set) var screenState: LoginScreenState = .initial
    @Published var userName: String = "sdbxaz-stg-amos"
    @Published var password: String = "fgKiPcSCiKquxGMQ"
    @Published var isFormValid: Bool = false
    
    private lazy var authenUseCase: MSBAuthenticationUseCase = {
        guard let useCase = Resolver.optional(MSBAuthenticationUseCase.self) else {
            fatalError("AuthenticationUseCase needed to continue")
        }
        return useCase
    }()
    
    private func login(fromEvent event: LoginScreenEvent) async {
        DispatchQueue.main.async {
            self.screenState = .loading
        }
        do {
            try await authenUseCase.login(userName: userName, password: password)
            DispatchQueue.main.async {
                self.screenState = .authenticated
            }
        } catch {
            DispatchQueue.main.async {
                self.screenState = .hasError
            }
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
    
    public init() {
        $userName
            .combineLatest($password)
            .map { !$0.isEmpty && !$1.isEmpty }
            .assign(to: &$isFormValid)
    }
}
