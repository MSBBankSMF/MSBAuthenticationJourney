//
//  BackbaseDelegateProxies.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 26/12/24.
//


import Backbase
import BackbaseIdentity

internal class BBIDAuthClientDelegateProxy: NSObject, BBIDAuthClientDelegate {
    typealias Result = Swift.Result<[String: String]?, MSBAuthenticationJourney.Error>
    typealias Handler = (Result) -> Void

    var handler: Handler

    required init(handler: @escaping Handler) {
        self.handler = handler
        super.init()
    }

    func oAuth2AuthClientInvalidateTokensDidFail(with error: Error) {
        handler(.failure(.init(sdk: error)))
    }

    func oAuth2AuthClientTokensDidInvalidate() {
        handler(.success(nil))
    }

    func oAuth2AuthClientAccessTokenDidRefresh(with headers: [String: String ]) {
        handler(.success(headers))
    }

    func oAuth2AuthClientAccessTokenDidFailToRefresh(with error: Error) {
        handler(.failure(.init(sdk: error)))
    }
}

internal final class BBIDFIDORegistrationDelegateProxy: NSObject, BBIDFIDORegistrationDelegate {
    typealias Result = Swift.Result<Void, MSBAuthenticationJourney.Error>
    typealias Handler = (Result) -> Void

    var handler: Handler

    required init(handler: @escaping Handler) {
        self.handler = handler
        super.init()
    }

    func uafRegistrationDidSucceed() {
        handler(.success(()))
    }

    func uafRegistrationDidFail(with error: Error) {
        handler(.failure(.init(sdk: error)))
    }
}

internal final class BBIDForgottenCredentialsDelegateProxy: NSObject, BBIDForgottenCredentialsDelegate, BBIDForgotPasscodeDelegate {
    typealias Result = Swift.Result<Data, MSBAuthenticationJourney.Error>
    typealias Handler = (Result) -> Void
    
    var usernameHandler: Handler?
    var passwordHandler: Handler?
    var passcodeHandler: Handler?
    
    required init(usernameHandler: Handler? = nil,
                  passwordHandler: Handler? = nil,
                  passcodeHandler: Handler? = nil) {
        self.usernameHandler = usernameHandler
        self.passwordHandler = passwordHandler
        self.passcodeHandler = passcodeHandler
        super.init()
    }

    func forgotUsernameDidSucceed(_ data: Data) {
        usernameHandler?(.success(data))
    }

    func forgotUsernameDidFailWithError(_ error: Error) {
        usernameHandler?(.failure(.init(sdk: error)))
    }

    func forgotPasswordDidSucceed(_ data: Data) {
        passwordHandler?(.success(data))
    }

    func forgotPasswordDidFailWithError(_ error: Error) {
        passwordHandler?(.failure(.init(sdk: error)))
    }
    
    func forgotPasscodeDidSucceed(_ headers: [String: String]) {
        let encoder = JSONEncoder()
        let dictionary = ["headers": headers]
        let data = try? encoder.encode(dictionary)
        if let data = data {
            passcodeHandler?(.success(data))
        } else {
            Backbase.logError(self, message: "Unable to encode header data")
        }
    }
    
    func forgotPasscodeDidFailWithError(_ error: Error) {
        // Using passcode error will change invalidCredentials to invalidPasscode error when the flow ends, which is not appropriate
        passcodeHandler?(.failure(.init(forgotPasscode: error)))
    }
}
