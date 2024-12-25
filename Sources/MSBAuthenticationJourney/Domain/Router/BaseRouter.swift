//
//  BaseRouter.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 24/12/24.
//
import BackbaseIdentity
import SwiftUI
import MSBLogger

public class BaseRouter: BBIDRouter, ObservableObject {
    public func onSuccess(context: BackbaseIdentity.BBIDRouterContext, contract: any BackbaseIdentity.BBIDRouterContract) {
        MSBLogger().debug("---BaseRouter2 onSuccess \(contract)")
//        if let routerView = presentedRouterView(for: context) {
//
//            if let newContract = contract as? Container.RouterInteractor.RouterData.Contract {
//
//                routerView.routerInteractor.routerData.contract = newContract
//            } else {
//                let expectedContract = Container.RouterInteractor.RouterData.Contract.self
//                AuthLogger.log(level: .error,
//                               message: "Type mismatch between received contract \(type(of: contract)) and expected contract \(expectedContract)")
//            }
//            routerView.onSuccess()
//        } else {
//            contract.finish(context: context)
//        }
    }
    
    public func onError(_ errorDetails: BackbaseIdentity.BBIDRouterError, context: BackbaseIdentity.BBIDRouterContext, contract: any BackbaseIdentity.BBIDRouterContract) {
        MSBLogger().debug("---BaseRouter2 onError \(errorDetails)")
    }
    
    
}
