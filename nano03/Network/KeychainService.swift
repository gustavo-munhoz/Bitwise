//
//  KeychainSetService.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 28/09/23.
//

import KeychainSwift

class KeychainService {
    private let keychain = KeychainSwift()
    
    func set(_ value: String, for key: String) {
        keychain.set(value, forKey: key)
    }
    
    func get(for key: String) -> String? {
        return keychain.get(key)
    }
    
    func delete(for key: String) {
        keychain.delete(key)
    }
}
