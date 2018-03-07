//
//  CalendarManager.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/2/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import Foundation


extension Int {
    func isSameOrLaterMonth(to month: Int) -> Bool {
        switch (self, month) {
        case (1, 12):
            return true
        case (12, 1):
            return false
        default:
            return self >= month
        }
    }
}

struct CalendarManager {
    let startDate: Date
    let endDate: Date
    
    lazy var nuberOfMounths: Int = {
        return Calendar.current.dateComponents([.month], from: startDate, to: endDate).month ?? 0
    }()
    
    func months(to date: Date) -> Int {
        return monthsCount(from: startDate, to: date)
    }
    
    private func monthsCount(from startDate: Date, to endDate: Date) -> Int {
        let startMonthAndYear = Calendar.current.dateComponents([.month, .year], from: startDate)
        guard let startMonth = startMonthAndYear.month, let startYear = startMonthAndYear.year else { return 0 }
        
        let endDateMonthAndYear = Calendar.current.dateComponents([.month, .year], from: endDate)
        guard let endMonth = endDateMonthAndYear.month, let endYear = endDateMonthAndYear.year else { return 0 }
        
        return (12 - startMonth) + (((endYear - startYear) - 1) * 12) + endMonth
    }
    
    func monthCalendar(at index: Int) -> MonthCalendar {
        guard  let date = Calendar.current.date(byAdding: .month, value: index, to: startDate) else {
            return MonthCalendar(month: 0, weeks: [[Date]]())
        }
        return monthCalendar(for: date)
    }
    
    func dateByAddingToStartDate(numOfMonth: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: numOfMonth, to: startDate)
    }
    
    func monthCalendar(for date: Date) -> MonthCalendar {
        let calendar =  Calendar.current
        let targetMonth = calendar.dateComponents([.month], from: date).month
        
        var componens = calendar.dateComponents([.year, .month, .weekday, .day], from: date)
        componens.day = 1
        
        guard  let firstDayOfMonth = calendar.date(from: componens),
            let firstDayOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth),
            let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 2, to: firstDayOfMonth) else {
                return MonthCalendar(month: targetMonth ?? 0, weeks: [[Date]]())
        }
        
        let daysDiff = calendar.dateComponents([.day], from: firstDayOfPreviousMonth, to: firstDayOfNextMonth)
        
        // TODO: Change to reduce
        var allDates = [Date]()
        (0..<(daysDiff.day ?? 0)).forEach { num in
            if let d = calendar.date(byAdding: .day, value: num, to: firstDayOfPreviousMonth) {
                allDates.append(d)
            }
        }
        let allComponents = allDates.map {
            Calendar.current.dateComponents([.year, .month, .weekday, .day], from: $0)
        }
        
        let allWeeks = allComponents.reduce(into: [[DateComponents]]()) { (weeks: inout [[DateComponents]], component) in
            if weeks.first == nil || (component.weekday != nil && component.weekday! == 1) {
                weeks.append([component])
            } else {
                weeks[weeks.count - 1].append(component)
            }
            }.filter { week in
                let monthOfTheLastDaysOfTheWeek = week.last?.month ?? 0
                let baseDateMonth = componens.month ?? 0
                return monthOfTheLastDaysOfTheWeek.isSameOrLaterMonth(to: baseDateMonth)
        }
        let weeks = allWeeks.map { week in
            week.map { component in
                calendar.date(from: component)
                }.flatMap { $0 }
            }.enumerated().filter { offset, _ in
                offset <= 5
            }.map {
                $0.1
        }
        
        return MonthCalendar(month: targetMonth ?? 0, weeks: weeks)
    }
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
}
