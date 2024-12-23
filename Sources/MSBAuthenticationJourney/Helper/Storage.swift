//
//  Storage.swift
//  MSBAuthenticationJourney
//
//  Created by Nicky on 22/12/24.
//
import Backbase

internal struct Storage {
    init(key: String) {
        self.key = key
    }

    var value: String? {
        get {
            return encryptedStorage?.getItem(key)
        }
        set {
            cacheValue(newValue)
        }
    }

    // MARK: - Private

    private let key: String

    private let encryptedStorage: StorageComponent? = {
        let storage = Backbase.registered(plugin: EncryptedStorage.self) as? EncryptedStorage
        return storage?.storageComponent
    }()

    private func cacheValue(_ value: String?) {
        guard let value = value else {
            encryptedStorage?.removeItem(key)
            return
        }
        encryptedStorage?.setItem(value, forKey: key)
    }
}
