//
//  NumberFormatter+Turkish.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import Foundation

extension NumberFormatter {
    static func turkishCurrencyFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

func formatTurkishCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter.turkishCurrencyFormatter()
    return formatter.string(from: NSNumber(value: amount)) ?? "0,00"
}
