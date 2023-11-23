//
//  TransactionService.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 27/09/23.
//

import Foundation
import Web3Core
import web3swift
import BigInt
import Combine

class TransactionService {
    static let shared = TransactionService()
    
    private let baseURL = "https://sepolia.infura.io/v3/\(Secret.shared.infuraApiKey)"
    
    let updates = PassthroughSubject<TransactionStatus, Never>()
    
    var transactionStatusPublisher = PassthroughSubject<Transaction, TransactionError>()
    
    private init() {}
    
    func sendTransaction(from wallet: Wallet, to recipientAddress: String, amount: Double) async throws -> String {
        var privateKey: String?
        guard let recipientEthereumAddress = EthereumAddress(recipientAddress) else {
            throw TransactionError.invalidRecipientAddress
        }
        
        guard let walletAddress = wallet.address else {
            throw TransactionError.invalidWalletAddress
        }
        
        do {
            privateKey = try wallet.keystore?.UNSAFE_getPrivateKeyData(password: "web3swift", account: wallet.address!).toHexString()
        } catch {
            print("Error getting private key: \(error)")
        }
        
        let valueInWei = BigUInt(amount * 1e18)
        
        var transaction: CodableTransaction = .emptyTransaction
        
        do {
            let nonce = try await Web3Manager.shared.web3!.eth.getTransactionCount(for: wallet.address!, onBlock: .pending)
            
            transaction.nonce = nonce
            transaction.from = walletAddress
            transaction.to = recipientEthereumAddress
            transaction.value = valueInWei
            transaction.gasPrice = try await Web3Manager.shared.web3!.eth.gasPrice() * 2
            transaction.gasLimit = 21000
            transaction.chainID = Web3Manager.shared.web3!.provider.network!.chainID
            try transaction.sign(privateKey: Data(hex: privateKey!))
            
        } catch {
            print("Error signing transaction: \(error)")
        }
        
        do {
            let signedTransactionData = transaction.encode()
            let transactionSendingResult = try await Web3Manager.shared.web3?.eth.send(raw: signedTransactionData!)
            
            if let transactionID = transactionSendingResult?.hash {
                let pendingTransaction = Transaction(
                    id: UUID(),
                    hash: transactionID,
                    date: Date(),
                    sender: wallet.address?.address,
                    receiver: recipientAddress,
                    status: .pending,
                    amount: amount
                )
                
                WalletManager.shared.addTransaction(pendingTransaction, for: wallet.type)
                return transactionID
            }
            
            return "Transaction failed: no id found."
            
        } catch {
            throw error
        }
    }
    
    func getTransactionReceipt(txhash: String, completion: @escaping (Result<TransactionReceipt, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Secret.shared.infuraApiKey, forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "id": 1,
            "method": "eth_getTransactionReceipt",
            "params": [txhash]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid payload"])))
            return
        }
        
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let result = json?["result"] as? [String: Any] else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                guard let blockNumberHex = result["blockNumber"] as? String else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Transaction not mined yet"])))
                    return
                }
                
                guard let blockNumber = Int(blockNumberHex.dropFirst(2), radix: 16) else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid block number"])))
                    return
                }
                
                guard let statusHex = result["status"] as? String, let statusInt = Int(statusHex.dropFirst(2), radix: 16) else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid status"])))
                    return
                }
                
                let status = statusInt == 1 ? TransactionStatus.completed : TransactionStatus.failed
                WalletManager.shared.updateTransactionStatus(hash: txhash, status: status, for: .ethereum)
                self.updates.send(status)
                
                let receipt = TransactionReceipt(blockNumber: blockNumber)
                completion(.success(receipt))
                
            } catch {
                completion(.failure(error)) 
            }
        }
        
        task.resume()
    }
}

struct TransactionReceipt {
    let blockNumber: Int
}
