//
//  ScannerController.swift
//  StarVault
//
//  Created by Laptop on 10/26/19.
//  Copyright © 2019 Armonia. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var cameraView: CameraView!
    let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    var captureSession     : AVCaptureSession?
    var videoPreviewLayer  : AVCaptureVideoPreviewLayer?
    
    
    @IBOutlet var imageScan: UIImageView!
    @IBOutlet weak var textMessage: UILabel!

    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCapture()
    }
    
    func startCapture() {
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!) // TODO: fix forced unwrapping
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the text label and top bar to the front
            view.bringSubviewToFront(imageScan)
            //view.bringSubview(toFront: textLabel)
            //view.bringSubview(toFront: topBar)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            textMessage.text = "ERROR"
            print(error)
            return
        }
        
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            print("No QR code is detected")
            //textLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            // let scanObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            // qrCodeFrameView?.frame = scanObject!.bounds
            
            if metadataObj.stringValue != nil {
                let qrCode = metadataObj.stringValue ?? ""
                print("QRCODE: ", qrCode)
                //textLabel.text = qrCode
                captureSession?.stopRunning()
                // REF: https://www.reddit.com/r/iOSProgramming/comments/5p1y0x/macos_swift_returning_data_from_a_view_controller/
                if let caller = presentingViewController as? QRCodeDelegate {
                    //if let caller = presentingViewController {
                    print("Caller processing")
                    caller.processData(qrCode)
                    //let x = caller as! QRCodeDelegate
                    //x.processData(qrCode)
                }
                goBack(self)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class CameraView: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    override var layer: AVCaptureVideoPreviewLayer {
        get {
            return super.layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    func updateOrientation() {
        let videoOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            videoOrientation = .portrait
            
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
            
        case .landscapeLeft:
            videoOrientation = .landscapeRight
            
        case .landscapeRight:
            videoOrientation = .landscapeLeft
            
        default:
            videoOrientation = .portrait
        }
        
        layer.connection?.videoOrientation = videoOrientation
    }
}


//----------------------------------------
// ANOTHER WAY TO SCAN QR CODES

class QrCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var calssName:String = "QrCodeScannerViewController"

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?

    @IBOutlet weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        captureQRCode()

    }


    /* Open camera to capture QR CODE */
    func captureQRCode() {
        captureSession = AVCaptureSession()
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

        let input = try! AVCaptureDeviceInput(device: device) as AVCaptureDeviceInput
        captureSession?.addInput(input)

        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession?.addOutput(output)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let bounds = self.view.layer.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.bounds = bounds
        videoPreviewLayer?.position = CGPoint(x:bounds.midX, y:bounds.midY)

        self.view.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
    }


    /* onAtivityResult from App Delegate */
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {
        for item in metadataObjects {
            if let metadataObject = item as? AVMetadataMachineReadableCodeObject {
                if metadataObject.type == AVMetadataObjectTypeQRCode {

                    print("QR Code: \(metadataObject.stringValue)")
                    hideCamera(voucherHashkey: metadataObject.stringValue)

                }
            }
        }

    }


    /* Hide camera after getting result */
    func hideCamera(voucherHashkey:String){

        self.captureSession?.stopRunning()
        self.videoPreviewLayer?.removeFromSuperlayer()
        self.videoPreviewLayer = nil;
        self.captureSession = nil;

        // sendVocherDataToServer(voucherHashKey: voucherHashkey)

    }
}


//----------------------------------------
// SIGN TRANSACTION


function sign() {
    var amount = $('amount').value;
    var destin = $('destin').value;
    var memo   = $('memo').value;

    StellarSdk.Network.usePublicNetwork();
    var server    = new StellarSdk.Server('https://horizon-testnet.stellar.org');
    var source    = StellarSdk.Keypair.fromSecret(secretKey);
    var operation = StellarSdk.Operation.payment({
        destination : destin,
        asset       : StellarSdk.Asset.native(),
        amount      : ''+amount
    });

    var account = new StellarSdk.Account(source.publicKey(), sequence);
    var builder = new StellarSdk.TransactionBuilder(account);
    builder.addOperation(operation);
    if(memo) { builder.addMemo(StellarSdk.Memo.text(memo)) }
    var transaction = builder.build();
    transaction.sign(source);
    var envelope = transaction.toEnvelope()
    var envXdr   = envelope.toXDR('base64');        // Signed
    var txXdr    = transaction.tx.toXDR('base64');  // Not signed
    console.log('TX', transaction);
    console.log('XDR', txXdr);
    console.log('ENV', envXdr);
    createQRCode(envXdr);
    $('xdr').innerHTML = envXdr;
}
