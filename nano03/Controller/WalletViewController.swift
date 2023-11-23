//
//  WalletViewController.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 29/09/23.
//

import UIKit
import Combine

class WalletViewController: UIViewController {
    
    private var walletView: WalletView
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables = Set<AnyCancellable>()
    
    init(of coin: Cryptocurrency) {
        walletView = WalletView(of: coin)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = walletView
        walletView.collectionView.delegate = self
        BalanceService.shared.fetchBalance(of: walletView.wallet!.type)
        configureDataSource()
        setupSubscriptions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        walletView.collectionView.collectionViewLayout = walletView.createLayout()
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: walletView.collectionView) { (collectionView, indexPath, itemType) -> UICollectionViewCell? in
            
            switch itemType {
            case .headerItem:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletHeaderCell", for: indexPath) as! WalletHeaderCell
                if let walletType = self.walletView.wallet?.type {
                    cell.configure(with: UIImage(named: walletType.details.header)!)
                }
                return cell
            
            case .balanceItem(let wallet):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BalanceCell", for: indexPath) as! BalanceCell
                cell.configure(with: wallet)
                cell.updateBalanceDisplay(from: wallet)
                cell.delegate = self
                
                return cell
                
            case .qrCodeItem(let wallet):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QRCodeCell", for: indexPath) as! QRCodeCell
                cell.configure(with: wallet)
                
                return cell
                
            case .transactionHistoryItem(let transactions):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionHistoryCell", for: indexPath) as! TransactionHistoryCell
                cell.configure(with: transactions)
                cell.delegate = self
                
                return cell
                
            case .spacing:
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpacingCell", for: indexPath) as! SpacingCell
               return cell
            
            default:
                fatalError("Unknown item type")
            }
        }
        
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        initialSnapshot.appendSections([.header])
        initialSnapshot.appendItems([.headerItem], toSection: .header)
        dataSource.apply(initialSnapshot, animatingDifferences: false)
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)

        snapshot.appendItems([.headerItem], toSection: .header)
        if let wallet = self.walletView.wallet {
            snapshot.appendItems([.balanceItem(wallet), .spacing(Spacing(id: UUID()))], toSection: .balanceAndTransaction)
            snapshot.appendItems([.qrCodeItem(wallet), .spacing(Spacing(id: UUID()))], toSection: .qrCode)
        }
        if let transactions = self.walletView.wallet?.transactions {
            snapshot.appendItems([.transactionHistoryItem(transactions.value)], toSection: .transactionHistory)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
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
                self.walletView.wallet!.balance!.send(newBalance)
                DispatchQueue.main.async {
                    WalletManager.shared.saveBalanceToKeychain(coin: .ethereum, balance: newBalance)
                    if let cell = self.walletView.collectionView
                        .cellForItem(at: IndexPath(item: 0, section: Section.balanceAndTransaction.rawValue)) as? BalanceCell {
                        cell.updateBalanceDisplay(from: self.walletView.wallet!)
                    }
                }
            })
            .store(in: &cancellables)
        
        TransactionService.shared.transactionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Transaction status publisher encountered an error: \(error)")
                }
            }, receiveValue: { [weak self] transaction in
                self?.transactionsDidUpdate()
            })
            .store(in: &cancellables)
        
        WalletManager.shared.getWallet(of: .ethereum)?.balance?
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error updating balance: \(error)")
                }
            }, receiveValue: { _ in
                DispatchQueue.main.async {
                    self.updateSnapshot()
                }
            })
            .store(in: &cancellables)
        
        WalletManager.shared.getWallet(of: .ethereum)?.transactions
            .sink { _ in
                DispatchQueue.main.async {
                    BalanceService.shared.fetchBalance(of: .ethereum)
                    self.updateSnapshot()
                }
            }
            .store(in: &cancellables)
        
        TransactionService.shared.updates
            .sink { _ in
                DispatchQueue.main.async {
                    self.transactionsDidUpdate()
                    self.updateSnapshot()
                }
            }
            .store(in: &cancellables)
    }
}

extension WalletViewController: BalanceCellDelegate {
    func didTapTransactionButton(in cell: BalanceCell) {
        let transactionVC = TransactionViewController(of: self.walletView.wallet!.type)
        if let presentationController = transactionVC.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        present(transactionVC, animated: true, completion: nil)
    }
}

extension WalletViewController: TransactionHistoryDelegate {
    func transactionsDidUpdate() {
        let indexPath = IndexPath(item: 0, section: Section.transactionHistory.rawValue)
        if let cell = walletView.collectionView.cellForItem(at: indexPath) as? TransactionHistoryCell {
            print("Updating cell at \(indexPath)")
            cell.updateTransactionDataSource(with: walletView.wallet!.transactions.value)
        } else {
            print("Failed to get cell at \(indexPath)")
        }
    }
}

extension WalletViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource.itemIdentifier(for: indexPath)
        
        switch item {
        case .spacing(_):
            return CGSize(width: collectionView.bounds.width, height: 32)
        default:
            break
        }
        
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 135)  // Tamanho para header
        case 1:
            return CGSize(width: collectionView.bounds.width, height: 110)  // Tamanho para balance
        case 2:
            return CGSize(width: collectionView.bounds.width, height: 220)  // Tamanho para qrcode
        case 3:
            return CGSize(width: collectionView.bounds.width, height: 220)  // Tamanho para history
        default:
            return UICollectionViewFlowLayout.automaticSize  // Tamanho automático para outras seções
        }
        
    }
}

struct Spacing: Hashable {
    let id: UUID
}

enum Section: Int, CaseIterable {
    case header
    case balanceAndTransaction
    case qrCode
    case transactionHistory
    case main
}

enum Item: Hashable {
    case headerItem
    case balanceItem(Wallet)
    case transactionButtonItem
    case qrCodeItem(Wallet)
    case transactionItem(Transaction)
    case transactionHistoryItem([Transaction])
    case spacing(Spacing)
}
