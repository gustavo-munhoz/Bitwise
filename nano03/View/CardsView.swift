//
//  CardsView.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 28/09/23.
//

import UIKit

class CardsView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    weak var cardDelegate: CardCellDelegate?
    private var cardNames: [String] = []  // Dados dos cartões
    private(set) var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = -125
        layout.itemSize = CGSize(width: 350, height: 180)
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 46).setActive()
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).setActive()
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).setActive()
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).setActive()
    }
    
    func getItemSize() -> CGSize {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.itemSize
        }
        return CGSize.zero
    }

    func getMinimumLineSpacing() -> CGFloat {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.minimumLineSpacing
        }
        return 0
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let card = cardNames[indexPath.item]
        cell.delegate = cardDelegate
        
        if let coin = Cryptocurrency.from(cardName: card) {
            cell.configure(with: coin)
        }
        return cell
    }


    
    // MARK: - Public methods
    
    func configure(with cardNames: [String]) {
        self.cardNames = cardNames
        collectionView.reloadData()
    }
}

