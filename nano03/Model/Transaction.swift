//
//  Transaction.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 28/09/23.
//

import Foundation

enum TransactionStatus: Codable {
    case pending
    case completed
    case failed
}

struct Transaction: Hashable, Codable {
    let id: UUID
    let hash: String
    let date: Date?
    let sender: String?
    let receiver: String?
    var status: TransactionStatus?
    let amount: Double?
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
