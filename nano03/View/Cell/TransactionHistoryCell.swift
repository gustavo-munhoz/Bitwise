//
//  TransactionHistoryCell.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 02/10/23.
//

import UIKit

protocol TransactionHistoryDelegate: AnyObject {
    func transactionsDidUpdate()
}

class TransactionHistoryCell: UICollectionViewCell {
    weak var delegate: TransactionHistoryDelegate?
    var transactionCollectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(named: "AppGray")
        label.text = "Transaction History"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTransactionCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTransactionCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: bounds.width, height: 90)
        
        transactionCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        transactionCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        transactionCollectionView.register(TransactionCell.self, forCellWithReuseIdentifier: "TransactionCell")
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(transactionCollectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
        
        transactionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            transactionCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            transactionCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            transactionCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            transactionCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: transactionCollectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .transactionItem(let transaction):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
                cell.configure(with: transaction)
                return cell
            default:
                fatalError("Unknown item type")
            }
        }
    }
    
    func configure(with transactions: [Transaction]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        let reversedTransactions = transactions.reversed()
        snapshot.appendItems(reversedTransactions.map { Item.transactionItem($0) }, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        delegate?.transactionsDidUpdate()
    }

    
    func updateTransactionDataSource(with transactions: [Transaction]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        let reversedTransactions = transactions.reversed()
        snapshot.appendItems(reversedTransactions.map { Item.transactionItem($0) }, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        transactionCollectionView.reloadData()
    }
}
