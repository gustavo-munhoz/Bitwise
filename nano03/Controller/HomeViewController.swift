//
//  ViewController.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 25/09/23.
//

import UIKit
import web3swift
import Web3Core
import Combine

class HomeViewController: UIViewController {
    let homeview = HomeView()
    
    var cancellables = Set<AnyCancellable>()

    override func loadView() {
        view = homeview
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupSubscriptions()
        
    }
    
    // MARK: Button functions
    
    
    private func didPullToRefreshBalance() {
//        BalanceService.shared.fetchBalance()
    }
    
    func showSendView() {
//        let receiveVC = TransactionViewController()
//        receiveVC.modalPresentationStyle = .pageSheet
//        present(receiveVC, animated: true, completion: nil)
    }

    @objc func didPressSendButton() {
        showSendView()
    }
    
    // MARK: Api functions
    
    func updateBalanceUponRefresh(completion: @escaping () -> Void) {
        homeview.didUpdateBalance(to: Balance.shared.balance.value!.description)
    }
    
    // MARK: Configuration
    
    private func setupButtons() {
        homeview.handleRefreshBalance = didPullToRefreshBalance
        homeview.handleSendButtonTap = didPressSendButton
    }
    
    private func setupSubscriptions() {
        BalanceService.shared.balanceUpdates
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error updating balance:", error)
                }
            }, receiveValue: { newBalance in
                Balance.shared.balance.send(newBalance)
                DispatchQueue.main.async {
                    WalletManager.shared.saveBalanceToKeychain(coin: .ethereum, balance: newBalance)
                    self.homeview.didUpdateBalance(to: newBalance.description)
                    self.homeview.refreshControlView.endRefreshing()
                }
            })
            .store(in: &cancellables)
    }
}

