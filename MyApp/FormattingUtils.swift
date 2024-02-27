//
//  FormattingUtils.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 27.02.2024.
//

import Foundation
import UIKit

class FormattingUtils {
    public static func UTCtoHoursInterval(_ seconds:Int) -> Int {
        let timeInSeconds = Int(Date().timeIntervalSince1970) - seconds
        return timeInSeconds/3600
    }

    // 5555 -> 5.5k
    public static func formatNumber(_ num:Int) -> String {
        
        if num < 1000 { return String(num) }
        else { return String(format: "%.1f", Double(num)/1000)+"k"}
    }

    public static func calculateTitleHeight(string:String, width: CGFloat, font: UIFont) -> CGFloat {
        
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = string.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}

