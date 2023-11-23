//
//  WalletManager.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 26/09/23.
//

import Foundation
import web3swift
import Web3Core
import KeychainSwift

class WalletManager {
    static let shared = WalletManager()
    
    private var wallets: [Cryptocurrency: Wallet] = [:]
    
    private let keychainService = KeychainService()
    
    private init() {}
    
    private func keychainKey(for property: KeychainProperty, coin: Cryptocurrency) -> String {
        return "\(coin.details.name)_\(property.rawValue)"
    }
    
    func setupWallet(for coin: Cryptocurrency) -> Wallet? {
        setupWalletOf(coin)
        return wallets[coin]
    }
    
    private func createWallet(for coin: Cryptocurrency, with mnemonic: String, transactions: [Transaction]) throws -> Wallet {
        let keystore = try BIP32Keystore(
            mnemonics: mnemonic,
            password: "web3swift",
            mnemonicsPassword: "",
            language: .english
        )
        return Wallet(type: coin, keystore: keystore, address: keystore?.addresses?.first, initialBalance: nil, transactions: transactions)
    }
    
    private func setupWalletOf(_ coin: Cryptocurrency) {
        do {
            let transactions = loadTransactions(for: coin) ?? []
            if let storedMnemonic = keychainService.get(for: keychainKey(for: .mnemonic, coin: coin)) {
                let wallet = try createWallet(for: coin, with: storedMnemonic, transactions: transactions)
                wallets[coin] = wallet
                
            } else {
                let newMnemonic = try BIP39.generateMnemonics(bitsOfEntropy: 128)!
                keychainService.set(newMnemonic, for: keychainKey(for: .mnemonic, coin: coin))
                let wallet = try createWallet(for: coin, with: newMnemonic, transactions: transactions)
                wallets[coin] = wallet
            }
        } catch {
            print("Error configuring wallet:", error)
        }
    }

    
    func saveBalanceToKeychain(coin: Cryptocurrency, balance: String) {
        keychainService.set(balance, for: keychainKey(for: .balance, coin: coin))
    }

    func getBalanceFromKeychain(for coin: Cryptocurrency) -> String? {
        return keychainService.get(for: keychainKey(for: .balance, coin: coin))
    }
    
    func getWallet(of coin: Cryptocurrency) -> Wallet? {
        return wallets[coin]
    }
    
    func addTransaction(_ transaction: Transaction, for coin: Cryptocurrency) {
        let wallet = getWallet(of: coin)
        var currentTransactions = wallet?.transactions.value ?? []
        currentTransactions.append(transaction)
        wallet?.transactions.send(currentTransactions)
        saveTransactions(currentTransactions, for: coin)
    }

    func updateTransactionStatus(hash: String, status: TransactionStatus, for coin: Cryptocurrency) {
        let wallet = getWallet(of: coin)
        var currentTransactions = wallet?.transactions.value ?? []
        if let index = currentTransactions.firstIndex(where: { $0.hash == hash }) {
            currentTransactions[index].status = status
            wallet?.transactions.send(currentTransactions)
            saveTransactions(currentTransactions, for: coin)
        }
    }
    
    func saveTransactions(_ transactions: [Transaction], for coin: Cryptocurrency) {
        let key = "\(coin.details.name)_transactions"
        if let encodedData = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encodedData, forKey: key)
        }
    }

    func loadTransactions(for coin: Cryptocurrency) -> [Transaction]? {
        let key = "\(coin.details.name)_transactions"
        if let data = UserDefaults.standard.data(forKey: key),
           let transactions = try? JSONDecoder().decode([Transaction].self, from: data) {
            return transactions
        }
        return nil
    }
}

enum KeychainProperty: String {
    case mnemonic = "mnemonic"
    case balance = "balance"
}
