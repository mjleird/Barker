//
//  Colors.swift
//  Barker
//
//  Created by Matt Leirdahl on 11/26/21.
//

import Foundation
import UIKit

class Colors{
    let mainColor = "#437909"
    let gradientSecondaryColor = "#2f9453"
    
    let boxMain = "#e67e22"
    let boxSecondary = "#c0392b"
    
    let complementatryMain = "#a5b1c2"
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
