//
//  BalanceService.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 25/09/23.
//

import UIKit
import Combine
import web3swift
import Web3Core

class BalanceService {
    static let shared = BalanceService()
    var balanceUpdates = PassthroughSubject<String, BalanceError>()
    
    func fetchBalance(of coin: Cryptocurrency) {
        let wallet = WalletManager.shared.getWallet(of: coin)!
        Task {
            do {
                guard let address = wallet.address else {
                    balanceUpdates.send(completion: .failure(.invalidAddress))
                    return
                }
                
                let weiValue = try await Web3Manager.shared.web3?.eth.getBalance(for: address)
                let etherValue = Double(weiValue!) / 1e18
                balanceUpdates.send("\(etherValue)")
            } catch {
                balanceUpdates.send(completion: .failure(.networkError))
            }
        }
    }
}
