//
//  Double+shortValue.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 10/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public extension Double {
    public func shortDisplayValue() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "no-NO")
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = 0
        
        if self <= 1000.0 {
            return "\(self)"
        } else if self > 1000.0 && self <= 100000.0 {
            let shortNumber = self/1000.0
            return "\(floor(shortNumber*10)/10)k"
        }
        
        return "\(self)"
    }
}
