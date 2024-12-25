//
//  FlowType.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 26/12/24.
//
import BackbaseIdentity

/// Flow types in Auth Journey that matches with `BBIDFlowType`
public enum FlowType: Equatable {
    case forgotUsername
    case forgotPassword
    case fidoAuthentication
    case fidoRegistration
    case forgotPasscode
    case inbandTransactionSigning
    case oobAuthentication
    case oobTransactionSigning
    case registration
    case sso
    case stepUp
    case usernamePasswordAuthentication
    case unknown
}

extension BBIDFlowType {
    public var authenticationFlowType: FlowType {
        switch self {
        case is BBIDFlowTypeForgotUsername:
            return .forgotUsername
        case is BBIDFlowTypeForgotPassword:
            return .forgotPassword
        case is BBIDFlowTypeFIDOAuthentication:
            return .fidoAuthentication
        case is BBIDFlowTypeFIDORegistration:
            return .fidoRegistration
        case is BBIDFlowTypeForgotPasscode:
            return .forgotPasscode
        case is BBIDFlowTypeInbandTransactionSigning:
            return .inbandTransactionSigning
        case is BBIDFlowTypeOOBAuthentication:
            return .oobAuthentication
        case is BBIDFlowTypeOOBTransactionSigning:
            return .oobTransactionSigning
        case is BBIDFlowTypeRegistration:
            return .registration
        case is BBIDFlowTypeSSO:
            return .sso
        case is BBIDFlowTypeStepUp:
            return .stepUp
        case is BBIDFlowTypeUsernamePasswordAuthentication:
            return .usernamePasswordAuthentication
        default:
            return .unknown
        }
    }
}
