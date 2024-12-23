//
//  MSBDelegateProxies.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import Backbase
import BackbaseIdentity

internal class PasswordAuthClientDelegateProxy: NSObject, PasswordAuthClientDelegate {
    typealias Result = Swift.Result<[String: String], Swift.Error>
    typealias Handler = (Result) -> Void

    var handler: Handler

    required init(handler: @escaping Handler) {
        self.handler = handler
        super.init()
    }

    func authenticationDidSucceed(with headers: [String: String]) {
        DispatchQueue.main.async {
            self.handler(.success(headers))
        }
    }

    func authenticationDidFail(with error: Error) {
        DispatchQueue.main.async {
            self.handler(.failure(error))
        }
    }
}


internal final class PasswordAuthClientResumingDelegateProxy: PasswordAuthClientDelegateProxy {
    typealias ResumingHandler = () -> Void

    var resumingHandler: ResumingHandler

    required init(handler: @escaping Handler, resumingHandler: @escaping ResumingHandler) {
        self.resumingHandler = resumingHandler
        super.init(handler: handler)
    }

    @available(*, unavailable)
    required init(handler: @escaping Handler) {
        fatalError()
    }

    func authenticationDidRequire(action response: HTTPURLResponse) {
        resumingHandler()
    }

    static func create(handler: @escaping Handler, resumingHandler: ResumingHandler? = nil) -> PasswordAuthClientDelegateProxy {
        if let resumingHandler = resumingHandler {
            return PasswordAuthClientResumingDelegateProxy(handler: handler, resumingHandler: resumingHandler)
        }
        return PasswordAuthClientDelegateProxy(handler: handler)
    }
}

internal final class AuthClientDelegateProxy: NSObject, AuthClientDelegate {
    typealias Handler = (SessionState) -> Void
    var handler: Handler

    required init(handler: @escaping Handler) {
        self.handler = handler
        super.init()
    }

    func sessionState(_ newSessionState: SessionState) {
        handler(newSessionState)
    }

    func sessionState(_ newSessionState: SessionState, withError error: Error!) {
        handler(newSessionState)
    }
}
