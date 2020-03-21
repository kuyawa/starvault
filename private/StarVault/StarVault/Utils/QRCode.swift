//
//  QRCode.swift
//  StarVault
//
//  Copyright © 2020 Kuyawa. All rights reserved.
//

import Foundation
import UIKit


protocol QRCodeDelegate: class {
    func processData(_ qrCode: String)
}

class QRCode {
    
    static func generate(text: String, size: Int) -> UIImage? {
        let data = text.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            //filter.setValue("L", forKey: "inputCorrectionLevel") // L low, M med, Q quality, H high
            
            if let output = filter.outputImage {
                let ratioW = size / Int(output.extent.size.width)
                let ratioH = size / Int(output.extent.size.height)
                let transform = CGAffineTransform(scaleX: CGFloat(ratioW), y: CGFloat(ratioH))
                
                //if let result = filter.outputImage?.applying(transform) {
                if let result = filter.outputImage?.transformed(by: transform) {
                    let image = UIImage(ciImage: result)
                    return image
                }
            }
        }
        
        return nil
    }
    
}
