//
//  LoginViewModel.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 12/11/24.
//


import Foundation
import Combine
import Resolver

final class LoginViewModel: NSObject {
    @Published private(set) var screenState: LoginScreenState = .initial
    @Published var userName: String = ""
    @Published var password: String = ""
    
    private lazy var authenUseCase: AuthenticationUseCase = {
        guard let useCase = Resolver.optional(AuthenticationUseCase.self) else {
            fatalError("AuthenticationUseCase needed to continue")
        }
        return useCase
    }()
    
    private func login(fromEvent event: LoginScreenEvent) {
        screenState = .loading
        do {
            try authenUseCase.login(userName: userName, password: password)
            screenState = .authenticated
        } catch {
            screenState = .hasError
        }
    }
    
    func onEvent(_ event: LoginScreenEvent) {
        switch event {
        case .login:
            login(fromEvent: event)
        }
    }


}
