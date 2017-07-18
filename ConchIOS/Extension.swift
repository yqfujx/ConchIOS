//
//  Extension.swift
//  ConchIOS
//
//  Created by osx on 2017/7/14.
//  Copyright © 2017年 osx. All rights reserved.
//

import Foundation

extension Date {
    init?(string: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        if let d = formatter.date(from: string) {
            self = d
        }
        else {
            return nil
        }
    }
    
    static func from(string: String, format: String) -> Date? {
        return Date(string: string, format: format)
    }
    
    func string(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}

extension UIButton {
    func setBackground(color: UIColor, forState state: UIControlState) -> Void {
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        let path = CGPath(roundedRect: rect, cornerWidth: 6, cornerHeight: 4, transform: nil)
        context?.addPath(path)
        context?.setFillColor(color.cgColor)
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor(white: 0, alpha: 0.65).cgColor)
        context!.drawPath(using: .fillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(image, for: state)
    }
}
