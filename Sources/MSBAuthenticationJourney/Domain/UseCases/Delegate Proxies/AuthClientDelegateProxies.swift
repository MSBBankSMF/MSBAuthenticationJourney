//
//  MSBDelegateProxies.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import Backbase
import BackbaseIdentity

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
