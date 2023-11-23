//
//  ReceiveViewController.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 26/09/23.
//

import UIKit

class ReceiveViewController: UIViewController {
    private let receiveView: ReceiveView

    init(address: String) {
        self.receiveView = ReceiveView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    override func loadView() {
        view = receiveView
    }
}
