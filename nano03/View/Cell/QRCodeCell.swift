//
//  QRCodeCell.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 29/09/23.
//

import UIKit

class QRCodeCell: UICollectionViewCell {
    var wallet: Wallet?
    
    private var bg: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.alpha = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        
        return view
    }()
    
    private var qrcode: UIButton = {
        let view = UIButton()
        view.tintColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(bg)
        contentView.addSubview(qrcode)
        
        qrcode.centerXAnchor.constraint(equalTo: centerXAnchor).setActive()
        qrcode.topAnchor.constraint(equalTo: topAnchor).setActive()
        qrcode.widthAnchor.constraint(equalToConstant: 200).setActive()
        qrcode.heightAnchor.constraint(equalToConstant: 200).setActive()
        
        bg.centerXAnchor.constraint(equalTo: centerXAnchor).setActive()
        bg.topAnchor.constraint(equalTo: topAnchor, constant: -15).setActive()
        bg.widthAnchor.constraint(equalToConstant: 230).setActive()
        bg.heightAnchor.constraint(equalToConstant: 230).setActive()
    }
    
    func configure(with wallet: Wallet) {
        self.wallet = wallet
        qrcode.setImage(CoreImageHelper.generateQRCode(from: wallet.address!.address), for: .normal)
        qrcode.addTarget(self, action: #selector(copyAddressToClipboard), for: .touchUpInside)
    }
    
    @objc func copyAddressToClipboard() {
        if let address = wallet?.address?.address {
            UIPasteboard.general.string = address
        }
    }
}
