//
//  State.swift
//  CalendarControl
//
//  Created by Andrey Volobuev on 2/14/18.
//  Copyright © 2018 Andrey Volobuev. All rights reserved.
//

import Foundation


enum CalendarState {
    case expanded(animated: Bool)
    case collapsed
    
    func toggled() -> CalendarState {
        switch self {
        case .expanded:
            return .collapsed
        case .collapsed:
            return .expanded(animated: false)
        }
    }
}

struct State: CustomStringConvertible {
    
    private static let dateFormatter: DateFormatter = { df in
        df.dateFormat = "dd.MM.yy mm:hh"
        return df
    }(DateFormatter())
    
    let calendar = Calendar.current
    
    let state: CalendarState
    let currentDate: Date
    let displayDate: Date
    let transactions: [(Date, Int)]
    
    func toggled() -> State {
        switch state {
        case .expanded:
            return State(state: .collapsed, currentDate: currentDate, displayDate: currentDate)
        case .collapsed:
            return State(state: .expanded(animated: false), currentDate: currentDate, displayDate: currentDate)
        }
    }
    
    func advance(by value: Int) -> State? {
        switch state {
        case .collapsed:
            guard let date = calendar.date(byAdding: .day, value: value, to: currentDate) else {
                return nil
            }
            return State(state: state, currentDate: date, displayDate: date)
        case .expanded:
            guard let month = calendar.date(byAdding: .month, value: value, to: displayDate) else {
                return nil
            }
            return State(state: .expanded(animated: true), currentDate: currentDate, displayDate: month)
        }
    }
    
    public var description: String {
        return "\n\t• \(state) current: \(State.dateFormatter.string(from: currentDate)) display: \(State.dateFormatter.string(from:displayDate))\n"
    }
    
    init(state: CalendarState, currentDate: Date, displayDate: Date, transactions: [(Date, Int)] = [(Date, Int)]() ) {
        self.state = state
        self.currentDate = currentDate
        self.displayDate = displayDate
        self.transactions = transactions
    }
}
