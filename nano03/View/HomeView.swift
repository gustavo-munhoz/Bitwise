//
//  HomeView.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 25/09/23.
//

import UIKit

class HomeView: UIScrollView, UITextFieldDelegate {
    var handleAddEtheriumButtonTap: () -> Void = {}
    var handleRefreshBalance: () -> Void = {}
    var handleReceiveButtonTap: () -> Void = {}
    var handleSendButtonTap: () -> Void = {}
    
    // MARK: Views
    
    private var balanceLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 40, weight: .bold)
        view.textColor = .green
        view.text = Balance.shared.balance.value
        
        return view
    }()
    
    private lazy var receiveIconView: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setBackgroundImage(UIImage(systemName: "qrcode"), for: .normal)
        view.tintColor = .black
        view.imageView?.contentMode = .scaleAspectFit
        view.addTarget(self, action: #selector(didPressReceiveButton), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var sendIconView: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        view.tintColor = .black
        view.imageView?.contentMode = .scaleAspectFit
        view.addTarget(self, action: #selector(didPressSendButton), for: .touchUpInside)
        
        return view
    }()
    
    lazy var refreshControlView: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()
    
    // MARK: initializers
    
    private func addSubviews() {
        addSubview(refreshControlView)
        addSubview(balanceLabel)
        addSubview(receiveIconView)
        addSubview(sendIconView)
    }
    
    private func setupConstraints() {
        balanceLabel.centerXAnchor.constraint(equalTo: centerXAnchor).setActive()
        balanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -150).setActive()
        
        receiveIconView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 75).setActive()
        receiveIconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 25).setActive()
        receiveIconView.widthAnchor.constraint(equalToConstant: 50).setActive()
        receiveIconView.heightAnchor.constraint(equalToConstant: 50).setActive()
        
        sendIconView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -75).setActive()
        sendIconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 25).setActive()
        sendIconView.widthAnchor.constraint(equalToConstant: 50).setActive()
        sendIconView.heightAnchor.constraint(equalToConstant: 50).setActive()
    }
    
    private func configureAdditionalSettings() {
        refreshControl = refreshControlView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubviews()
        setupConstraints()
        configureAdditionalSettings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: Methods for handling buttons and changes
    
    func didUpdateBalance(to value: String) {
        balanceLabel.text = value
    }
    
    @objc
    func didPressAddEthButton() {
        handleAddEtheriumButtonTap()
    }
    
    @objc
    private func refreshData(_ sender: UIRefreshControl) {
        handleRefreshBalance()
    }
    
    @objc
    private func didPressReceiveButton() {
        handleReceiveButtonTap()
    }
    
    @objc
    private func didPressSendButton() {
        handleSendButtonTap()
    }
}
