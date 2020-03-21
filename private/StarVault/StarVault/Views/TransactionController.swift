//
//  TransactionController.swift
//  StarVault
//
//  Copyright © 2020 Kuyawa. All rights reserved.
//

import UIKit
import StellarSDK

class TransactionController: UIViewController {

    @IBOutlet weak var imgCode: UIImageView!
    
    @IBAction func onScanner(_ sender: Any) {
        let view = ScannerController()
        present(view, animated: true)
    }

    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        main()
    }

    func main() {
        imgCode.border(width: 1, color: UIColor.lightGray.cgColor)
        processData("?")
    }

    // Process data on returning from ScannerController view
    func processData(_ qrCode: String) {
        print("Received: ", qrCode)
        //textAccount.text = qrCode
        
        // TODO: Determine tx type, if payment proceed
        // TODO: Split data in parts
        // web+stellar:pay?destination=GA123456&amount=10.00&memo=hello
        
        let qrCode = "web+stellar:pay?destination=GCBFBRFSWDAUOB5BTNHAWBIWTX5QWDEMKRGUBVVFQVT46THNUTIOSIDM&amount=25&memo=hello"
        //let qrCode = "web+stellar:tx?xdr=abcdefg123456"
        //let qrCode = "nothing to see here"
        
        let dixy = qrCode.urlParts()
        print("Dixy",dixy)

        if dixy["type"] == "pay" {
            print("Payment!")
        }
        
        // TODO: if valid tx then sign and generate qrcode
        let tx = signPayment(dixy)
        showTransaction(tx)
    }
    
    
    func signPayment(_ dixy: [String:String]) -> String {
        
        // First, load account from keychain
        let key = Keychain.load("starvault")
        print("Key: [\(key)]")
        
        if key.isEmpty {
            print("No key")
            return ""
        }
        
        guard let account = StellarSDK.Account.fromSecret(key) else {
            print("No account")
            return ""
        }
        
        print("Public: \(account.publicKey)")
        
        //let source = KeyPair.getPublicKey(account.publicKey)!
        //let secret = KeyPair.getSignerKey(account.secretKey)!
        
        // Parse fields
        //let network = dixy["network"] ?? ""
        let amount = Double(dixy["amount"] ?? "0") ?? 0
        let address = dixy["destination"] ?? ""
        //let assetCode = dixy["assetCode"] ?? ""
        //let assetIssuer = dixy["assetIssuer"] ?? ""
        //let asset = Asset(assetCode: assetCode, issuer: assetIssuer) ?? Asset.Native
        let memo = dixy["memo"] ?? ""

        //guard let destin = KeyPair.getPublicKey(address) else {
        //    print("Invalid address to send payment")
        //    return ""
        //}
        
        //let inner  = PaymentOp(destination: destin, asset: asset, amount: Int64(amount * 10000000.0)) // Seven decimals
        //let body   = OperationBody.Payment(inner)
        //let op     = Operation(sourceAccount: source, body: body)
        
        //let builder = TransactionBuilder(source)
        //builder.setNetwork(network)
        //builder.setSequence(account.sequence)
        //builder.addOperation(op)
        //builder.addMemoText(memo)
        //builder.build()
        //builder.sign(key: secret)
        // Return payment TX for QRCodes
        //let response = builder.txHash
        
        // TODO: if qrcode received as tx in base 64 instead of sep007
        //let builder  = StellarSDK.TransactionBuilder(tx: base64)
        //let envelope = builder.sign(key: secret)
        //let xdr64 = builder.txHash
        //return xdr64
        
        let tx = account.paymentOffline(address: address, amount: amount, memo: memo)
        print("response",tx)
        if tx.error {
            print("ERROR:",tx.message)
        }
        return tx.text

    }
    
    func showTransaction(_ tx: String) {
        print("tx", tx)
        imgCode.image = QRCode.generate(text: tx, size: Int(imgCode.frame.width))
    }
    
}
