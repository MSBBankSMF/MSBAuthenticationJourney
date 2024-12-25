//
//  MSBAuthenticationJourneyExampleApp.swift
//  MSBAuthenticationJourneyExample
//
//  Created by doandat on 11/11/24.
//

import SwiftUI
import MSBAuthenticationJourney

@main
struct MSBAuthenticationJourneyExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @State private var isConfigured = false
    
    var body: some View {
        if isConfigured {
            LoginScreen(viewModel: LoginViewModel(session: .none))
        } else {
            ProgressView("Configuring...")
                .onAppear {
                    configure()
                }
        }
    }
    
    private func configure() {
        Task { @MainActor in
            BackbaseService()
            MSBAuthenticationJourney.Configuration().register()
            isConfigured = true
        }
    }
    
//    func handleSessionChange(_ session: IdentityAuthenticationJourney.Session) {
//        guard let service = getRegisteredService(class: BackbaseService.self) else { return }
//        DispatchQueue.main.async {
//            MSBLogger().debug("handleSessionChange session: \(session)")
//            switch session {
//            case .valid:
////                WindowManagementService.shared.msbSession = .valid
////                WindowManagementService.shared.msbSession = .workspace //POC
//                break
//            case .none:
//                MSBLogger().debug("handleSessionChange isEnrolled: \(service.authenticationUseCase.isEnrolled)")
////                if service.authenticationUseCase.isEnrolled {
////                    WindowManagementService.shared.msbSession = .none(isEnrolled: true)
////                } else {
////                    WindowManagementService.shared.msbSession = .none(isEnrolled: false)
////                }
//            case .locked:
////                WindowManagementService.shared.msbSession = .locked
//            case .expired:
////                WindowManagementService.shared.msbSession = .expired
//            @unknown default:
//                fatalError()
//            }
//        }
//    }
}
