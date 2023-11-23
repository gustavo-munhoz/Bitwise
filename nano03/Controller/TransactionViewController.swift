//
//  TransactionViewController.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 26/09/23.
//

import UIKit

class TransactionViewController: UIViewController, UITextFieldDelegate, QRCodeViewControllerDelegate {
    
    // MARK: Properties
    
    private let transactionView = TransactionView()
    private var scannerVC: QRCodeScannerViewController?
    private var type: Cryptocurrency
    
    // MARK: Lifecycle
    
    init(of coin: Cryptocurrency) {
        type = coin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupButtons()
    }
    
    private func setupView() {
        view = transactionView
        transactionView.delegate = self
        transactionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            transactionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            transactionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            transactionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            transactionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func setupButtons() {
        transactionView.handleSendButtonTap = didTapSendButton
        transactionView.handleQRCodeButtonTap = didTapQRCodeButton
    }
    
    // MARK: Actions
    
    private func didTapSendButton() {
        WebSocketService.shared.connect()
        
        guard let recipientAddress = transactionView.recipientAddressTextField.text, !recipientAddress.isEmpty else {
            showAlert(message: "Please enter a recipient address.")
            return
        }
        
        guard let amountString = transactionView.amountTextField.text?.replacingOccurrences(of: ",", with: "."), let amount = Double(amountString), amount > 0 else {
            showAlert(message: "Please enter a valid amount.")
            return
        }
        
        Task {
            do {
                let result = try await TransactionService.shared.sendTransaction(
                    from: WalletManager.shared.getWallet(of: .ethereum)!,
                    to: recipientAddress ,
                    amount: Double(amountString)!)
                WebSocketService.shared.subscribeToTransactionUpdates(transactionID: result)
                
                print("Transaction Result: \(result)")
                
//                let status = EtherscanService.shared.getTransactionReceiptStatus(txhash: result)
//                print(status)
            } catch {
                print("Error sending transaction: \(error)")
            }
        }
        
        
        showAlert(message: "Transaction sent!")
    }
    
    private func didTapQRCodeButton() {
        scannerVC?.view.removeFromSuperview()
        scannerVC = nil
        
        scannerVC = QRCodeScannerViewController()
        scannerVC?.delegate = self
        transactionView.cameraView.addSubview(scannerVC!.view)
        scannerVC!.view.frame = transactionView.cameraView.bounds
        
        scannerVC!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scannerVC!.view.topAnchor.constraint(equalTo: transactionView.cameraView.topAnchor),
            scannerVC!.view.bottomAnchor.constraint(equalTo: transactionView.cameraView.bottomAnchor),
            scannerVC!.view.leadingAnchor.constraint(equalTo: transactionView.cameraView.leadingAnchor),
            scannerVC!.view.trailingAnchor.constraint(equalTo: transactionView.cameraView.trailingAnchor)
        ])
    }

    func didScanCode(_ code: String) {
        transactionView.recipientAddressTextField.text = code
        transactionView.toggleCameraView { _ in
            self.scannerVC?.view.removeFromSuperview()
            self.scannerVC = nil
        }
    }
    
    // MARK: Helper Functions
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

