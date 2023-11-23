//
//  BalanceViewCell.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 29/09/23.
//

import UIKit

protocol BalanceCellDelegate: AnyObject {
    func didTapTransactionButton(in cell: BalanceCell)
}

class BalanceCell: UICollectionViewCell {
    weak var delegate: BalanceCellDelegate?
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(named: "AppGray")
        return label
    }()
    
    private var balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 41, weight: .bold)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.text = "Loading..."
        return label
    }()
    
    private var transactionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "paperplane.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        self.addSubview(titleLabel)
        self.addSubview(balanceLabel)
        self.addSubview(transactionButton)
        
        // Constraints for titleLabel
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).setActive()
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).setActive()
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).setActive()
        
        transactionButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).setActive()
        transactionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).setActive()
        transactionButton.widthAnchor.constraint(equalToConstant: 40).setActive()
        transactionButton.heightAnchor.constraint(equalToConstant: 40).setActive()
        
        // Constraints for balanceLabel
        balanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -5).setActive()
        balanceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).setActive()
        balanceLabel.trailingAnchor.constraint(equalTo: transactionButton.leadingAnchor, constant: -8).setActive()
        
        transactionButton.addTarget(self, action: #selector(handleTransactionButton), for: .touchUpInside)
    }
    
    func configure(with wallet: Wallet) {
        titleLabel.text = "My \(wallet.type.details.name) balance"
        balanceLabel.text = wallet.balance?.value ?? "Fetching..."
    }
    
    func updateBalanceDisplay(from wallet: Wallet) {
        if let balance = wallet.balance {
            balanceLabel.text = "\(String(describing: balance.value ?? "Fetching...")) \(wallet.type.details.name)"
        }
    }
    
    @objc
    private func handleTransactionButton() {
        delegate?.didTapTransactionButton(in: self)
    }
}
