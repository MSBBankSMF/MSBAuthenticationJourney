//
//  Routers.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 25/12/24.
//
import BackbaseIdentity
import Resolver
import MSBLogger

internal struct Routers {
    let passcode = PasscodeRouter()
    let biometric = BiometricRouter()
//    let inputRequired = InputRequired.router
//    let otpMethodChoice = OTP.methodChoiceRouter
//    let outOfBandAuthSessionRouter = OutOfBandAuthenticationConfirmLogin.router
//    let otpInput = OTP.inputRouter
//    let termsAndConditions = TermsAndConditions.router
//    let updatePassword = UpdatePassword.router
//    let changePasscode = ChangePasscode.router

    func registerAll(using client: BBIDAuthClient) {
        register(router: passcode, using: client)
        register(router: biometric, using: client)
//
//        register(router: otpMethodChoice, using: client)
//        register(router: otpInput, using: client)
//        register(router: inputRequired, using: client)
//        register(router: updatePassword, using: client)
//        register(router: outOfBandAuthSessionRouter, using: client)
//        register(router: termsAndConditions, using: client)
//        register(router: changePasscode, using: client)
    }

    func reRegisterAllFIDO(using client: BBIDAuthClient) {
        MSBLogger().debug("Registering FIDO routers (may fail due to already being added)")
        register(router: passcode, using: client)
        register(router: biometric, using: client)
    }

    func prepareForBiometric(in client: BBIDAuthClient) {
        MSBLogger().debug("Registering biometric router (may fail due to already being added)")
        unregister(router: BBIDPasscodeRouter.self, using: client)
        register(router: biometric, using: client)
    }

    func prepareForPasscode(in client: BBIDAuthClient) {
        MSBLogger().debug("Registering passcode router (may fail due to already being added)")
        register(router: passcode, using: client)
        unregister(router: BBIDBiometricsRouter.self, using: client)
    }

    // MARK: Private

    private func register(router: BBIDRouter, using client: BBIDAuthClient) {
        do {
            try client.addRouter(router)
        } catch {
            MSBLogger().warning( "Failed to add \(router.self) router: \(error)")
        }
    }

    private func unregister<T: BBIDRouter>(router: T.Type, using client: BBIDAuthClient) {
        do {
            try client.removeRouters(ofType: router)
        } catch {
            MSBLogger().warning("Failed to remove \(router.self) router: \(error)")
        }
    }
}
