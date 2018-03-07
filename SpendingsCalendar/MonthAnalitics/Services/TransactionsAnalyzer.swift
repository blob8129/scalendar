//
//  TransactionsAnalyzer.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/6/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import Foundation


final class TransactionsAnalyzer {
    
    private(set) var periods = [[Period]]()
    
    private let calendar = Calendar.current
    private var savings = [Period]()
    private var gains = [Period]()
    private var spendings = [Period]()
    private var amountsByWeekDays = [Int: Double]()
    
    func analyzeTransactions(for startDate: Date, to endDate: Date, using amountProvider: AmountProvider) {
        guard let days = calendar.dateComponents([.day], from: startDate, to: endDate).day else { return }
        let dates = (1...days).flatMap {
            calendar.date(byAdding: .day, value: $0, to: startDate)
        }
        let dailyAmounts = dates.map { date in
            (date: date, amount: amountProvider.getAmount(for: date))
        }
        savings = dailyAmounts.split { dailyAmount in
            dailyAmount.amount != 0
            }.flatMap { items in
                Period(type: .savings, items: Array(items))
        }
        gains = dailyAmounts.split { dailyAmount in
            dailyAmount.amount <= 0
            }.flatMap { items in
                Period(type: .increase, items: Array(items))
        }
        spendings = dailyAmounts.split { dailyAmount in
            dailyAmount.amount >= 0
            }.flatMap { items in
                Period(type: .spendings, items: Array(items))
        }
        periods = calculatePeriods()
        amountsByWeekDays = calculateAmountsByWeekDays(for: dailyAmounts)
    }
    
    func getMaxSpendingsWeekDay() -> (String, Double)? {
        let max = amountsByWeekDays.max { amount1, amoun2 in
            amount1.value > amoun2.value
        }
        guard let maxAmount = max else { return nil }
        
        return (calendar.weekdaySymbols[maxAmount.0 - 1], maxAmount.1)
    }
    
    func getMaxSavigsWeekDay() -> (String, Double)? {
        let max = amountsByWeekDays.max { amount1, amoun2 in
            amount1.value < amoun2.value
        }
        guard let maxAmount = max else { return nil }
        
        return (calendar.weekdaySymbols[maxAmount.0 - 1], maxAmount.1)
    }
    
    func getPosition(for date: Date) -> RelativePriodPosition {
        return  getPosition(for: date, in: spendings + gains)
    }
    
    private func getPosition(for date: Date, in periods: [Period]) -> RelativePriodPosition {
        let relativePositions: [RelativePriodPosition] = periods.map { period in
            let startCompare = self.calendar.compare(period.start, to: date, toGranularity: .day)
            let endCompare = self.calendar.compare(period.end, to: date, toGranularity: .day)
            switch (startCompare, endCompare) {
            case (ComparisonResult.orderedSame, ComparisonResult.orderedSame):
                return .firstAndLast
            case (ComparisonResult.orderedSame, _):
                return .first
            case (_, ComparisonResult.orderedSame):
                return .last
            case (ComparisonResult.orderedAscending, ComparisonResult.orderedDescending):
                return .middle
            default:
                return .none
            }
           
        }
        return relativePositions.first(where: { position in
            position != .none
        }) ?? .none
    }
    
    private func calculatePeriods() ->  [[Period]] {
        let all = [savings, gains, spendings]
        let longest = all.flatMap { periods in
            periods.max { period1, period2  in
                period1.dutation < period2.dutation
            }
        }
        let allSorted = all.flatMap { $0 }.sorted(by: { period1, period2  in
            period1.start > period2.start
        })
        return [longest, allSorted]
    }
    
    private func calculateAmountsByWeekDays(for dailyAmounts: [(date: Date, amount: Double)]) ->  [Int: Double] {
        let weekDayAmount: [(Int, Double)] = dailyAmounts.map { dailyAmount in
            let weekDay = calendar.component(.weekday, from: dailyAmount.date)
            return (weekDay, dailyAmount.amount)
        }
        return  weekDayAmount.reduce(into: [Int: Double]()) { (result, item) in
            result[item.0, default: 0.0] += item.1
        }
    }
}
