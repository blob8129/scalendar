//
//  Transaction.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/6/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import Foundation


struct Transaction {
    let id: String
    let amount: Double
    let date: Date
    let accountNumber: String
    let type: String
}

extension Transaction: Equatable {
    static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.id == rhs.id && lhs.amount == rhs.amount && lhs.accountNumber == rhs.accountNumber
    }
}

extension Transaction: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}
