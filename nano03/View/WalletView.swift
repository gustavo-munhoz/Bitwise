//
//  WalletView.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 29/09/23.
//

import UIKit

class WalletView: UIView {
    var collectionView: UICollectionView!
    private(set) var wallet: Wallet?
    
    init(of coin: Cryptocurrency) {
        self.wallet = WalletManager.shared.setupWallet(for: coin)
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(WalletHeaderCell.self, forCellWithReuseIdentifier: "WalletHeaderCell")
        collectionView.register(BalanceCell.self, forCellWithReuseIdentifier: "BalanceCell")
        collectionView.register(QRCodeCell.self, forCellWithReuseIdentifier: "QRCodeCell")
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: "TransactionHistoryCell")
        collectionView.register(SpacingCell.self, forCellWithReuseIdentifier: "SpacingCell")
        collectionView.contentInsetAdjustmentBehavior = .never
        self.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
}
