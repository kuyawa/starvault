//
//  Extensions.swift
//  StarVault
//
//  Copyright © 2020 Kuyawa. All rights reserved.
//

import Foundation
import UIKit

typealias Completion = (_ message: String) -> ()

extension String {
    
    func subtext(from ini: Int, to end: Int) -> String {
        guard ini >= 0 else { return "" }
        guard end >= 0 else { return "" }
        var fin = end
        if ini > self.count { return  "" }
        if end > self.count { fin = self.count }
        let first = self.index(self.startIndex, offsetBy: ini)
        let last  = self.index(self.startIndex, offsetBy: fin)
        let range = first ..< last
        let text = self[range]
        
        return String(text)
    }
    
    var money: String {
        if let num = Double(self) {
            return num.money
        } else {
            return (0.0).money
        }
    }
    
    func toMoney(_ decs: Int, comma: Bool) -> String {
        if let num = Double(self) {
            return num.money
        } else {
            //let zero = 0.0
            return (0.0).money
        }
    }
    
    var dateISO: Date {
        var date = Date(timeIntervalSince1970: 0)
        if !self.isEmpty {
            //let formatter = ISO8601DateFormatter() // Available on macOS 10.12
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = formatter.date(from: self) ?? date
        }
        return date
    }
    
    func ellipsis(_ n: Int) -> String {
        if self.isEmpty { return "" }
        return self.subtext(from: 0, to: n) + "..."
    }
}

extension Int {
    var str: String { return String(describing: self) }
    var on: Bool { return self > 0 }
}

extension Double {
    var money: String {
        let value = NSNumber(value: self)
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let text = formatter.string(from: value) ?? "0.00"
        //let text = NumberFormatter.localizedString(from: value, number: .decimal)
        //let text = String(format:"%.2f", self)
        return text
    }
    
    var moneyBlank: String {
        if self == 0.0 { return "" }
        return self.money
    }
}

extension Date {
    var string: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let text = formatter.string(from: self)
        return text
    }
    
    static func fromString(_ text: String, format: String) -> Date {
        var date = Date(timeIntervalSince1970: 0)
        if !text.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            date = formatter.date(from: text)!
        }
        return date
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var month3: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
    
}

extension Bool {
    var int: UInt8 { return self ? 0x1 : 0x0 }
}

extension UIColor {
    
    // Use: UIColor(0xffffffff)
    convenience init(hex: Int) {
        var opacity : CGFloat = 1.0
        if hex > 0xffffff {
            opacity = CGFloat((hex >> 24) & 0xff) / 255
        }
        let parts = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255,
            A: opacity
        )
        //print(parts)
        self.init(red: parts.R, green: parts.G, blue: parts.B, alpha: parts.A)
    }
    
    // Use: UIColor(RGB:(128,255,255))
    convenience init(RGB: (Int, Int, Int)) {
        self.init(
            red  : CGFloat(RGB.0)/255,
            green: CGFloat(RGB.1)/255,
            blue : CGFloat(RGB.2)/255,
            alpha: 1.0
        )
    }
    
}

extension UIImageView {
    func border(width: CGFloat? = 1.0, color: CGColor? = UIColor.black.cgColor) {
        self.layer.borderWidth = width!
        self.layer.borderColor = color!
    }
}

// myImage.image = anyImage.border(width: 100, color: UIColor.black)
extension UIImage {
    func bordered(width: CGFloat, color: UIColor) -> UIImage? {
        let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension String {
    func urlSplit() -> [String: String] {
        var dixy: [String: String] = [:]
        
        let tranx = self.components(separatedBy: "?")
        if tranx.count > 1 {
            let prefix = tranx[0]
            let proto = prefix.components(separatedBy: ":")
            if proto.count < 2 { /* no stellar protocol? return all string */
                return ["data":self]
            }
            
            dixy["type"] = proto[1]
            
            let parts = tranx[1] as String
            let fields = parts.components(separatedBy: "&")
            
            // loop fields, split by =
            for field in fields {
                let args = field.components(separatedBy: "=")
                let arg = args[0]
                let val = args[1]
                dixy[arg] = val
                print("arg:", val)
            }
        } else {
            dixy["data"] = self  // url is data, no extra fields
        }
        
        return dixy
    }
    
    func urlParts() -> [String: String] {
        guard let parts = URLComponents(string: self) else {
            return ["data": self]  // No components? return whole string
        }
        
        var dixy: [String: String] = [:]
        dixy["scheme"] = parts.scheme
        dixy["type"] = parts.path
        
        guard let items = parts.queryItems else { return dixy }
        
        for field in items {
            dixy[field.name] = field.value
        }
        
        return dixy
    }
}

// END
