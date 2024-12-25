//
//  LoginScreen.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//

import SwiftUI
import Combine
import BackbaseIdentity
import Resolver

public struct LoginScreen: View {
    @ObservedObject public var viewModel: LoginViewModel
    @ObservedObject var biometricRouter: BiometricRouter = Resolver.resolve(BBIDBiometricsRouter.self) as! BiometricRouter
    @ObservedObject var passcodeRouter: PasscodeRouter = Resolver.resolve(BBIDPasscodeRouter.self) as! PasscodeRouter

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            TextField("Username", text: $viewModel.username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            if viewModel.screenState == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                Button(action: {
                    viewModel.onEvent(.login)
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(!viewModel.isFormValid)
            }
            
            if viewModel.screenState == .hasError {
                Text("Login failed. Please try again.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}

