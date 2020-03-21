//
//  MainController.swift
//  StarVault
//
//  Copyright © 2020 Kuyawa. All rights reserved.
//

import UIKit
import StellarSDK

class ViewController: UIViewController {

    @IBOutlet weak var buttonSign: UIButton!
    
    @IBAction func onSignTransaction(_ sender: Any) {
        let view = TransactionController()
        present(view, animated: true)
    }

    @IBAction func onAccountSetup(_ sender: Any) {
        let view = AccountController()
        present(view, animated: true)
    }

    override func viewDidLoad() {
        print("loaded")
        super.viewDidLoad()
        main()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("appeared")
        super.viewWillAppear(animated)
        checkAccount()
    }

    func main() {
        //checkAccount()
    }
    
    func checkAccount() {
        // Check if account exists else disable sign button
        print("checking")
        let key = Keychain.load("starvault")
        print("Key: [\(key)]")
        
        if key.isEmpty {
            print("No key")
            buttonSign.isEnabled = false
            return
        }
        
        guard let account = StellarSDK.Account.fromSecret(key) else {
            print("No account")
            buttonSign.isEnabled = false
            return
        }
        
        print("Public: \(account.publicKey)")
    }



}

