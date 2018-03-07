//
//  Period.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/6/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import Foundation


struct Period {
    enum PeriodType: String {
        case increase = "Increase"// 📈"
        case spendings = "Spendings" //💸"
        case savings = "Savings"// 💰"
    }
    let type: PeriodType
    let dutation: Int
    let start: Date
    let end: Date
    let amount: Double
}

struct PeriodViewModel {
    let type: String
    let period: String
    let amount: String
    let isPositive: Bool
}

extension Period {
    func toViewModel(using dateFormatter: DateFormatter) -> PeriodViewModel {
        let startDate = dateFormatter.string(from: start)
        let endDate = dateFormatter.string(from: end)
        let period = start.compare(end) == .orderedSame ? startDate : "\(startDate) - \(endDate)"
        return PeriodViewModel(type: type.rawValue,
                               period: period,
                               amount: String(format: amount.noZeroFormat(), amount),
                               isPositive: amount >= 0)
    }
}

extension Period {
    init?(type: PeriodType, items: [(date: Date, amount: Double)]) {
        guard let startDate = items.first?.date, let endDate = items.last?.date  else {
            return nil
        }
        let amount = items.reduce(0) { result, item in
            result + item.amount
        }
        self.type = type
        self.dutation = items.count
        self.start = startDate
        self.end = endDate
        self.amount = amount
    }
}
