//
//  ScannerController.swift
//  StarVault
//
//  Copyright © 2020 Kuyawa. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var cameraView: CameraView!
    
    // AV capture session and dispatch queue
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "Session Queue")
    
    var isShowingAlert = false
    
    @IBOutlet var imageScan: UIImageView!
    @IBOutlet weak var textMessage: UILabel!

    override func loadView() {
        cameraView = CameraView()
        view = cameraView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Barcode Scanner"
        session.beginConfiguration()
        
        if let videoDevice = AVCaptureDevice.default(for: .video) {
            if let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                
                metadataOutput.metadataObjectTypes = [
                    .code128,
                    .code39,
                    .code93,
                    .ean13,
                    .ean8,
                    .qr,
                    .upce
                ]
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
        }
        
        session.commitConfiguration()
        cameraView.layer.session = session
        cameraView.layer.videoGravity = .resizeAspectFill
        
        // Set initial camera orientation
        cameraView.updateOrientation()
        
        //view.bringSubviewToFront(imageScan)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start AV capture session
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop AV capture session
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Update camera orientation
        cameraView.updateOrientation()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Display barcode value
        if !isShowingAlert,
            metadataObjects.count > 0,
            metadataObjects.first is AVMetadataMachineReadableCodeObject,
            let scan = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            let code = scan.stringValue ?? ""
            print("QR:", code)
            
            // Show alert
            //let alertController = UIAlertController(title: "Barcode Scanned", message: scan.stringValue, preferredStyle: .alert)
            //isShowingAlert = true
            //alertController.addAction(UIAlertAction(title: "OK", style: .default) { action in
            //    self.isShowingAlert = false
            //})
            //present(alertController, animated: true)
            
            self.session.stopRunning()

            if let caller = self.presentingViewController as? QRCodeDelegate {
                print("Caller processing")
                caller.processData(code)
            }
            
            self.dismiss(animated: true)
        }
    }
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

// END
