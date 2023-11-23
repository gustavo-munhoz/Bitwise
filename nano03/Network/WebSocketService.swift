//
//  WebSocketService.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 30/09/23.
//


import Starscream
import ObjectiveC
import UIKit

class WebSocketService: NSObject, WebSocketDelegate {
    static var shared = WebSocketService()
    
    var transactionHashesToMonitor: Set<String> = []
    var confirmationsCount: [String: Int] = [:]
    
    private var socket: WebSocket!
    private let serverURL = URL(string: "wss://sepolia.infura.io/ws/v3/\(Secret.shared.infuraApiKey)")!
    
    func connect() {
        socket = WebSocket(request: URLRequest(url: serverURL))
        socket.delegate = self
        socket.connect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("Websocket connected: \(headers)")
            // Enviar mensagem de subscrição para transações pendentes após a conexão ser estabelecida
            let subscriptionMessage = "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"eth_subscribe\", \"params\": [\"newPendingTransactions\"]}"
            client.write(string: subscriptionMessage)

        case .disconnected(let reason, let code):
            print("Websocket disconnected: \(reason) with code = \(code)")
            
        case .text(let string):
            if let data = string.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let params = jsonObject["params"] as? [String: Any],
               let result = params["result"] as? String {
                   
                if transactionHashesToMonitor.contains(result) {
                    print("Starting to monitor transaction status for hash: \(result)")
                    // Chamar a função checkTransactionStatus para começar a monitorar o status da transação
                    checkTransactionStatus(hash: result)
                }
            }
            
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("Websocket cancelled")
        case .error(let error):
            print("Websocket found an error: \(error?.localizedDescription ?? "Unknown")")
        default:
            return
        }
    }
    
    func handleReceivedMessage(_ message: String) {
        if let data = message.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let jsonDict = jsonObject as? [String: Any],
           let status = jsonDict["status"] as? String {
           
           print("Transaction status: \(status)")
        }
    }

    func subscribeToTransactionUpdates(transactionID: String) {
        transactionHashesToMonitor.insert(transactionID)
    }

    func checkTransactionStatus(hash: String) {
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            TransactionService.shared.getTransactionReceipt(txhash: hash) { result in
                switch result {
                case .success(let receipt):
                    let blockNumber = receipt.blockNumber
                    print("Transaction \(hash) mined in block \(blockNumber)")
                    timer.invalidate()
                
                case .failure(let error):
                    print("Error checking transaction status: ", error)
                }
            }
        }
        timer.fire()
    }
    
    
    func reconnect() {
        socket.connect()
    }
}
