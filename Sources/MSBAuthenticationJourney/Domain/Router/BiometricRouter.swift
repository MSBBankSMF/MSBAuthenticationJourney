//
//  BiometricRouter.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 24/12/24.
//
import BackbaseIdentity
import SwiftUI

enum PincodeFlowLogin {
    case create
    case confirmRegister(String)
    case confirmLogin
}

class BiometricRouter: BBIDBiometricsRouter, ObservableObject {
    @Published var isShowBiometric: Bool = false
   
    var context: BackbaseIdentity.BBIDRouterContext?
    var contract: BackbaseIdentity.BBIDBiometricsRouterContract?

    /// Called when the router needs to prompt user for biometric authentication
    /// - Parameters:
    ///   - context: context for the flow
    ///   - contract: contract for the flow
    ///   - data: data for the flow
    func promptForBiometrics(context: BackbaseIdentity.BBIDRouterContext,
                             contract: BackbaseIdentity.BBIDBiometricsRouterContract,
                             data: BackbaseIdentity.BBIDBiometricsRouterData) {
        let flowType = context.flowType?.authenticationFlowType ?? .unknown
        self.context = context
        self.contract = contract
        switch flowType {
        case
            .oobAuthentication,
            .fidoAuthentication:
            print("---these flows won't present any view")
            // these flows won't present any view
//            connector.readyToProvideBiometrics(context: context, contract: contract)

        default:
            print("---go to biometric")
            isShowBiometric.toggle()
        }
    }

    func readyToProvideBiometrics() {
        guard let context = context, let contract = contract else { return }
        contract.readyToProvideBiometrics(context: context)
    }
    
    func userDidSkip() {
        guard let context = context, let contract = contract else { return }
        contract.skip(context: context)
        isShowBiometric = false
    }
    

    // MARK: - Handle the success and error distinctly here for specific cases

    func onSuccess(context: BBIDRouterContext, contract: BBIDRouterContract) {
        let flowType = context.flowType?.authenticationFlowType ?? .unknown
        switch flowType {
        case .oobAuthentication,
             .fidoAuthentication:
            break
        default:
            isShowBiometric = false
            contract.finish(context: context)
            print("BiometricRouter2 on success")
        }
    }

    func onError(_ errorDetails: BBIDRouterError, context: BBIDRouterContext, contract: BBIDRouterContract) {
        let flowType = context.flowType?.authenticationFlowType ?? .unknown
        switch flowType {
        case .oobAuthentication,
             .fidoAuthentication:
            break
        default:
            print("BiometricRouter2 \(errorDetails)")
        }
    }
}
