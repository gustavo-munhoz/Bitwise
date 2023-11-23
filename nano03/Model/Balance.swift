//
//  Balance.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 25/09/23.
//

import Combine

struct Balance {
    static let shared = Balance()
    private(set) var balance = CurrentValueSubject<String?, Error>(WalletManager.shared.getBalanceFromKeychain(for: .ethereum))
    
    private init() {}
}
