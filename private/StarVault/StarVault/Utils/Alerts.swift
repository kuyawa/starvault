//
//  Alerts.swift
//  StarVault
//
//  Copyright © 2020 Kuyawa. All rights reserved.
//

import UIKit
import Foundation


extension UIViewController {
    func showStatus(_ text: String) {
        let alert = UIAlertController(title: "Mooney", message: text, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showWarning(_ text: String) {
        let alert = UIAlertController(title: "Mooney", message: text, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showToast(_ text: String, time: Int? = 2) {
        let left   = 20
        let top    = Int(self.view.frame.size.height - 100) // from bottom
        let width  = min(330, Int(self.view.frame.size.width  -  40)) // padding 20 max 330
        let height = 35
        let toastLabel = UILabel(frame: CGRect(x: left, y: top, width: width, height: height))
        let interval = TimeInterval(time ?? 2)
        
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = text
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds =  true
        
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: interval, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

// END
