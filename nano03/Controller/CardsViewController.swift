//
//  CardsViewController.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 29/09/23.
//

import UIKit

class CardsViewController: UIViewController, CardCellDelegate {
    private var cardsView = CardsView()
    private var cardsData: [String] = [
        Cryptocurrency.ethereum.details.cardAssetName
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Bitwise"
    }
    
    func setupView() {
        view = cardsView
        cardsView.configure(with: cardsData)
        cardsView.cardDelegate = self
    }
    
    func cardCellWasTapped(_ cell: CardCell) {
        let walletVC = WalletViewController(of: cell.type)
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
}

