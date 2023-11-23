//
//  Wallet.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 28/09/23.
//

import Foundation
import web3swift
import Web3Core
import Combine

struct Wallet: Hashable {
    let id: UUID = UUID()
    let type: Cryptocurrency
    var keystore: BIP32Keystore?
    var address: EthereumAddress?
    var balance: CurrentValueSubject<String?, Error>?
    var pendingBalance: String?
    var transactions: CurrentValueSubject<[Transaction], Never>
    
    static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(type: Cryptocurrency, keystore: BIP32Keystore?, address: EthereumAddress?, initialBalance: String?, transactions: [Transaction]) {
        self.type = type
        self.keystore = keystore
        self.address = address
        self.balance = CurrentValueSubject<String?, Error>(initialBalance)
        self.transactions = CurrentValueSubject(transactions)
    }
}
