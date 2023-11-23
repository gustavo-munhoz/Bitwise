//
//  SendView.swift
//  nano03
//
//  Created by Gustavo Munhoz Correa on 26/09/23.
//

import UIKit

class TransactionView: UIView, UITextFieldDelegate {
    var handleQRCodeButtonTap: () -> Void = {}
    var handleSendButtonTap: () -> Void = {}
    weak var delegate: QRCodeViewControllerDelegate?
    
    private var cameraViewHeightConstraint: NSLayoutConstraint!
    private var qrCodeScannerVC: QRCodeScannerViewController!
    
    // MARK: Views
    
    private(set) lazy var recipientAddressTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Recipient Address"
        textField.borderStyle = .roundedRect
        textField.rightView = readQRCodeButton
        textField.rightViewMode = .always
        
        return textField
    }()
    
    private(set) var cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var readQRCodeButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        view.addTarget(self, action: #selector(didPressQRCodeButton), for: .touchUpInside)

        return view
    }()
    
    private(set) var amountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Amount"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(didPressSendButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: initializers
    
    private func addSubviews() {
        addSubview(cameraView)
        addSubview(recipientAddressTextField)
        addSubview(amountTextField)
        addSubview(sendButton)
    }
    
    private func setupConstraints() {
        cameraView.centerXAnchor.constraint(equalTo: centerXAnchor).setActive()
        cameraView.topAnchor.constraint(equalTo: topAnchor, constant: 20).setActive()
        cameraView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).setActive()
        cameraView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).setActive()
        cameraViewHeightConstraint = cameraView.heightAnchor.constraint(equalToConstant: 0)
        cameraViewHeightConstraint.setActive()
        
        recipientAddressTextField.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 20).setActive()
        recipientAddressTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).setActive()
        recipientAddressTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).setActive()
        recipientAddressTextField.heightAnchor.constraint(equalToConstant: 44).setActive()
        
        amountTextField.topAnchor.constraint(equalTo: recipientAddressTextField.bottomAnchor, constant: 20).setActive()
        amountTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).setActive()
        amountTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).setActive()
        amountTextField.heightAnchor.constraint(equalToConstant: 44).setActive()
        
        sendButton.centerXAnchor.constraint(equalTo: centerXAnchor).setActive()
        sendButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).setActive()
        sendButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).setActive()
        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).setActive()
        sendButton.heightAnchor.constraint(equalToConstant: 44).setActive()
    }

    
    private func configureAdditionalSettings() {
        recipientAddressTextField.delegate = self
        amountTextField.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tapGesture)
        
        addSubviews()
        setupConstraints()
        configureAdditionalSettings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: Button functions
    
    func toggleCameraView(completion: ((Bool) -> Void)? = nil) {
        if cameraViewHeightConstraint.constant == 0 {
            cameraViewHeightConstraint.constant = 200
        } else {
            cameraViewHeightConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }, completion: completion)
    }

    
    @objc private func didPressQRCodeButton() {
        handleQRCodeButtonTap()
        toggleCameraView()
    }
    
    @objc
    private func didPressSendButton() {
        handleSendButtonTap()
    }
    
    // MARK: UITextFieldDelegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}
