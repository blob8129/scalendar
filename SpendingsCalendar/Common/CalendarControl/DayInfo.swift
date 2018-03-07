//
//  DayInfo.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/7/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import Foundation

enum RelativePriodPosition {
    case first
    case middle
    case last
    case firstAndLast
    case none
}

extension RelativePriodPosition: CustomStringConvertible {
    var description: String {
        get {
            switch self {
            case .first:
                return "First"
            case .middle:
                return "Middle"
            case .last:
                return "Last"
            case .firstAndLast:
                return "FirstAndLast"
            case .none:
                return "None"
            }
        }
    }
}

public struct DayInfo {
    enum DayInfoType {
        case positive
        case negative
    }
    let type: DayInfoType
    let info: String
    let position: RelativePriodPosition
}

extension DayInfo {
    init(amount: Double, position: RelativePriodPosition) {
        let type: DayInfoType
        let info: String
        if amount == 0  {
            type = .positive
            info =  ""
        } else {
            type = amount >= 0 ? .positive : .negative
            info =  String(format: amount.noZeroFormat(), amount)
        }
        self.type = type
        self.info = info
        self.position = position
    }
}
