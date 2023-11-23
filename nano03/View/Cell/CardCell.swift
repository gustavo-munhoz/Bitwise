//
//  CardCell.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 28/09/23.
//

import UIKit

protocol CardCellDelegate: AnyObject {
    func cardCellWasTapped(_ cell: CardCell)
}

class CardCell: UICollectionViewCell {
    weak var delegate: CardCellDelegate?
    private var cardImageView: UIImageView!
    private(set) var type: Cryptocurrency
    
    override init(frame: CGRect) {
        self.type = .ethereum
        super.init(frame: frame)
        setupCell()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    func configure(with coin: Cryptocurrency) {
        self.type = coin
        cardImageView.image = UIImage(named: type.details.cardAssetName)
    }
    
    private func setupCell() {
        cardImageView = UIImageView(image: UIImage(named: type.details.cardAssetName))
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.clipsToBounds = true
        
        self.addSubview(cardImageView)
        
        // Se você quiser usar Auto-Layout em vez de frames diretos:
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardImageView.topAnchor.constraint(equalTo: self.topAnchor),
            cardImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cardImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func cardTapped() {
        delegate?.cardCellWasTapped(self)
    }
}


