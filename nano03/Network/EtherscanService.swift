//
//  EtherscanService.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 30/09/23.
//

import Foundation
import Combine

class EtherscanService {
    static var shared = EtherscanService()
    
    private let baseURL = "https://api.etherscan.io/api"
    
    func getTransactionBlockNumber(txhash: String) throws -> Int {
        let endpoint = "\(baseURL)?module=transaction&action=gettxinfo&txhash=\(txhash)&apikey=\(Secret.shared.etherscanApiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, _, error) = URLSession.shared.syncDataTask(with: url)
        
        if let error = error {
            throw error
        }
        
        guard let data = data else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No data"])
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON response: \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(EtherscanTransactionResponse.self, from: data)
        return Int(response.result.blockNumber.dropFirst(2), radix: 16)!
    }

    private struct EtherscanTransactionResponse: Codable {
        let result: TransactionResult
        
        struct TransactionResult: Codable {
            let blockNumber: String
        }
    }
}

extension URLSession {
    func syncDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        return (data, response, error)
    }
}
