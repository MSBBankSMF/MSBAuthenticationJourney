//
//  BiometryType.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import LocalAuthentication

/// Represents cases for the biometric sensor in the device.
public enum BiometryType {
    /// Sensor not available.
    case none

    /// Face ID.
    case faceID

    /// Touch ID.
    case touchID

    /// Passcode.
    case passcode

    /// Biometric sensor usage denied by the system.
    case denied

    /// Biometric sensor is locked out.
    case lockedOut

    internal init(_ biometryType: LABiometryType) {
        switch biometryType {
        case .faceID:
            self = .faceID
        case .touchID:
            self = .touchID
        case .opticID:
            self = .none
        case .none:
            self = .none
        @unknown default:
            self = .none
        }
    }

    /// Biometry type currently supported by the device (`.lockedOut` if biometry is locked out).
    public static var supported: BiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if error?.code == LAError.biometryLockout.rawValue {
            return .lockedOut
        }
        return .init(context.biometryType)
    }
    
    /// Biometry type supported by the device, regardless of biometry lockout
    public static var supportedByDevice: BiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return .init(context.biometryType)
    }

    /// Biometry type allowed by the system (`.lockedOut` if biometry is locked out or `.denied` if denied by the user).
    public static var allowed: BiometryType {
        let context = LAContext()
        var error: NSError?

        let hasAuthenticationBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if error != nil {
            if error?.code == LAError.biometryLockout.rawValue {
                return .lockedOut
            }
            return .denied
        }

        let hasAuthentication = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if error != nil {
            return .denied
        }

        if hasAuthenticationBiometrics || hasAuthentication {
            return .init(context.biometryType)
        }

        return .none
    }
}
