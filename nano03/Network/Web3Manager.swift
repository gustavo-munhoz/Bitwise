//
//  Web3Manager.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 26/09/23.
//

import web3swift
import Web3Core
import UIKit
import BigInt

class Web3Manager {
    static let shared = Web3Manager()
    var web3: Web3?
    
    private init() {
        setupWeb3()
    }
    
    private func setupWeb3() {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                let sepoliaChainID: BigUInt = 11155111
                let provider = try await Web3HttpProvider(url: URL(string: "https://sepolia.infura.io/v3/\(Secret.shared.infuraApiKey)")!, network: .Custom(networkID: sepoliaChainID))
                web3 = Web3(provider: provider)
            } catch {
                print("Error fetching provider:", error.localizedDescription)
            }
            semaphore.signal()
        }
        
        semaphore.wait()
    }
}

