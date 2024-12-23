//
//  LoginScreen.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 21/12/24.
//

import SwiftUI
import Combine

public struct LoginScreen: View {
    @ObservedObject public var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            TextField("Username", text: $viewModel.userName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if viewModel.screenState == .loading {
                ProgressView()
                    .padding()
            } else {
                Button(action: {
                    viewModel.onEvent(.login)
                }) {
                    Text("Login")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
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

