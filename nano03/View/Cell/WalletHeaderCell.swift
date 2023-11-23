//
//  WalletHeaderCell.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 29/09/23.
//

import UIKit

class WalletHeaderCell: UICollectionViewCell {
    private var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        addSubview(headerImageView)
        
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: topAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with image: UIImage) {
        headerImageView.image = image
    }
}
