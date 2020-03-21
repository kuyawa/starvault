//
//  AccountController.swift
//  StarVault
//
//  Copyright © 2020 Kuyawa. All rights reserved.
//

import UIKit
import StellarSDK

class AccountController: UIViewController {
    
    @IBOutlet weak var textPublic: UITextField!
    @IBOutlet weak var textSecret: UITextField!
    @IBOutlet weak var imgKey: UIImageView!
    @IBOutlet weak var buttonGenerate: UIButton!
    @IBOutlet weak var buttonScan: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var keySelector: UISegmentedControl!
    
    @IBAction func onGenerate(_ sender: Any) {
        generateKeys()
    }
    
    @IBAction func onScanner(_ sender: Any) {
        let view = ScannerController()
        present(view, animated: true)
    }
    
    @IBAction func onSelected(_ sender: UISegmentedControl) {
        showKey()
    }
    
    @IBAction func onSave(_ sender: Any) {
        saveAccount()
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        print("loaded")
        super.viewDidLoad()
        imgKey.border(width: 1, color: UIColor.lightGray.cgColor)
        main()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("appeared")
        super.viewWillAppear(animated)
    }
    
    func main() {
        checkAccount()
    }
    
    func checkAccount() {
        // Get account from keychain if available
        let key = Keychain.load("starvault")
        print("Key: [\(key)]")
        
        if key.isEmpty {
            print("No key")
            return
        }
        
        guard let account = StellarSDK.Account.fromSecret(key) else {
            print("No account")
            return
        }
        
        // Show account info
        refreshInfo(account)
        showKey()
        //disableActions() // TODO: ENABLE!
    }

    func generateKeys() {
        let account = StellarSDK.Account.random()
        refreshInfo(account)
        showKey()
    }
    
    func refreshInfo(_ account: StellarSDK.Account) {
        print("Public: \(account.publicKey)")
        print("Secret: \(account.secretKey)")
        textPublic.text = account.publicKey
        textSecret.text = account.secretKey
    }
    
    func showKey() {
        var key = ""
        if keySelector.selectedSegmentIndex == 0 {
            key = textPublic.text ?? ""
        } else {
            key = textSecret.text ?? ""
        }
        imgKey.image = QRCode.generate(text: key, size: Int(imgKey.frame.width))

    }
    
    func saveAccount() {
        // TODO: verify secret starts with S and is 56 chars long
        guard let key = textSecret.text else { print("No secret"); return }
        if Keychain.save("starvault", key) {
            disableActions()
        }
    }
    
    func disableActions() {
        buttonSave.isEnabled = false
        buttonScan.isEnabled = false
        buttonGenerate.isEnabled = false
    }
    
    // Process data on returning from ScannerController view
    func processData(_ qrCode: String) {
        print("Received: ", qrCode)
        //textAccount.text = qrCode
        
        // TODO: Determine key must be secret
        let secretText = "S..."
        let publicText = "P..." // Calc from secret
        textPublic.text = publicText
        textSecret.text = secretText
        showKey()
    }
    
}
