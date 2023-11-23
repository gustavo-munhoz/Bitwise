//
//  Cryptocurrency.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 28/09/23.
//

import Foundation

enum Cryptocurrency: Hashable {
    case ethereum
    
    var details: Details {
        switch self {
        case .ethereum:
            return Details(name: "ETH", header: "header_eth", cardAssetName: "card_eth")
        }
    }
    
    struct Details {
        let name: String
        let header: String
        let cardAssetName: String
    }
}

extension Cryptocurrency {
    static func from(cardName: String) -> Cryptocurrency? {
        switch cardName {
        case "card_eth":
            return .ethereum
        default:
            return nil
        }
    }
}
