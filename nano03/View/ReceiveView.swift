//
//  ReceiveView.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 26/09/23.
//

import UIKit

class ReceiveView: UIView {
    // MARK: Views
    
    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 32, weight: .bold)
        view.textColor = .black
        view.numberOfLines = 2
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        view.text = "Share this QRCode receive payment"
        
        return view
    }()
    
    private lazy var qrcodeView: UIImageView = {
        let view = UIImageView(image: CoreImageHelper.generateQRCode(from: "a"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: initializers
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(qrcodeView)
    }
    
    private func setupConstraints() {
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -200).setActive()
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50).setActive()
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50).setActive()
        
        qrcodeView.centerXAnchor.constraint(equalTo: centerXAnchor).setActive()
        qrcodeView.centerYAnchor.constraint(equalTo: centerYAnchor).setActive()
        qrcodeView.widthAnchor.constraint(equalToConstant: 200).setActive()
        qrcodeView.heightAnchor.constraint(equalToConstant: 200).setActive()
    }
    
    private func configureAdditionalSettings() {
    
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
    
}
