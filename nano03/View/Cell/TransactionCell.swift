//
//  TransactionCell.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 02/10/23.
//

import UIKit

class TransactionCell: UICollectionViewCell {
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(named: "AppGray2")
        return label
    }()
    
    private var senderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var receiverLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var statusTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var statusValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .bold)
        return label
    }()
    
    private var backgroundBox: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "AppLightGray")
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        addSubview(backgroundBox)
        backgroundBox.addSubview(dateLabel)
        backgroundBox.addSubview(senderLabel)
        backgroundBox.addSubview(receiverLabel)
        backgroundBox.addSubview(statusTextLabel)
        backgroundBox.addSubview(statusValueLabel)
        
        backgroundBox.topAnchor.constraint(equalTo: topAnchor).setActive()
        backgroundBox.bottomAnchor.constraint(equalTo: bottomAnchor).setActive()
        backgroundBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).setActive()
        backgroundBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).setActive()
        
        dateLabel.topAnchor.constraint(equalTo: backgroundBox.topAnchor, constant: 8).setActive()
        dateLabel.leadingAnchor.constraint(equalTo: backgroundBox.leadingAnchor, constant: 12).setActive()
        dateLabel.trailingAnchor.constraint(equalTo: backgroundBox.trailingAnchor, constant: -12).setActive()
        
        senderLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6).setActive()
        senderLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor).setActive()
        senderLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor).setActive()
        
        receiverLabel.topAnchor.constraint(equalTo: senderLabel.bottomAnchor).setActive()
        receiverLabel.leadingAnchor.constraint(equalTo: senderLabel.leadingAnchor).setActive()
        receiverLabel.trailingAnchor.constraint(equalTo: senderLabel.trailingAnchor).setActive()
        
        statusTextLabel.topAnchor.constraint(equalTo: receiverLabel.bottomAnchor, constant: 6).setActive()
        statusTextLabel.bottomAnchor.constraint(equalTo: backgroundBox.bottomAnchor, constant: -8).setActive()
        statusTextLabel.leadingAnchor.constraint(equalTo: senderLabel.leadingAnchor).setActive()
        
        statusValueLabel.leadingAnchor.constraint(equalTo: statusTextLabel.trailingAnchor, constant: 4).setActive()
        statusValueLabel.topAnchor.constraint(equalTo: statusTextLabel.topAnchor).setActive()
        statusValueLabel.bottomAnchor.constraint(equalTo: statusTextLabel.bottomAnchor).setActive()
    }
    
    func configure(with transaction: Transaction) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateLabel.text = dateFormatter.string(from: transaction.date!)
        senderLabel.text = "\(String(describing: transaction.sender!))"
        receiverLabel.text = "To: \(String(describing: transaction.receiver!))"
        statusTextLabel.text = "Status:"
        
        switch transaction.status {
        case .pending:
            statusValueLabel.text = "Pending"
            statusValueLabel.textColor = UIColor(named: "AppOrange")
            
        case .completed:
            statusValueLabel.text = "Completed"
            statusValueLabel.textColor = UIColor(named: "AppGreen")
            
        default:
            statusValueLabel.text = "Failed"
            statusValueLabel.textColor = UIColor(named: "AppRed")
        }
    }
}
