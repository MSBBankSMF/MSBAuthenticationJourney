//
//  PasscodeRouter2.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 24/12/24.
//
import BackbaseIdentity
import Resolver
import SwiftUI
import MSBLogger
import Combine

class PasscodeRouter: BBIDPasscodeRouter, ObservableObject {
    @Published var isShowPincode: Bool = false
//    @Published var isShowConfirmPincode: Bool = false
    @Published var pincodeFlowLogin: PincodeFlowLogin?
    @Published var messagerError: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    private var context: BackbaseIdentity.BBIDRouterContext?
    private var contract: BackbaseIdentity.BBIDPasscodeRouterContract?

    func promptForPasscode(context: BackbaseIdentity.BBIDRouterContext, contract: any BackbaseIdentity.BBIDPasscodeRouterContract, data: BackbaseIdentity.BBIDPasscodeRouterData) {
        let authenticationUseCase: MSBAuthenticationUseCase = Resolver.resolve()
        isShowPincode.toggle()
        self.context = context
        self.contract = contract
        pincodeFlowLogin = authenticationUseCase.isEnrolled ? .confirmLogin : .create
    }

    func onSuccess(context: BackbaseIdentity.BBIDRouterContext, contract: any BackbaseIdentity.BBIDRouterContract) {
        isShowPincode = false
        contract.finish(context: context)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.resumeAuthentication()
        })
        MSBLogger().debug("--PasscodeRouter2 onSuccess")
    }

    func onError(_ errorDetails: BackbaseIdentity.BBIDRouterError, context: BackbaseIdentity.BBIDRouterContext, contract: any BackbaseIdentity.BBIDRouterContract) {
        MSBLogger().debug("--PasscodeRouter2 onError\(errorDetails)")
        messagerError = errorDetails.error.localizedDescription
    }

    func entered(passcode: String) {
        if let context = context {
            contract?.entered(passcode: passcode, context: context)
        }
    }

    func replayRegistration() {
        if let context = context {
            contract?.replayRegistration(context: context)
        }
    }

    func onSkip() {
        isShowPincode = false
//        isShowConfirmPincode = false
        if let context = context {
            contract?.skip(context: context)
        }
    }

//    func confirmPincodeFlow(text: String) {
//        isShowPincode.toggle()
//        pincodeFlowLogin = .confirmRegister(text)
//        isShowConfirmPincode.toggle()
//    }

    func resumeAuthentication() {
        let authenticationUseCase = Resolver.resolve(MSBAuthenticationUseCaseImp.self)
        authenticationUseCase.sessionSubject
            .sink { session in
                print(session)
            }
            .store(in: &cancellables)
        authenticationUseCase.validateSession()
    }
}
