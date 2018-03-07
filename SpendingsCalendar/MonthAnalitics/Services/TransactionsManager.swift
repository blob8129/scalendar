//
//  TransactionsManager.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/6/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import Foundation


protocol AmountProvider {
    func getAmount(for date: Date) -> Double
}

final class TransactionsManager: AmountProvider {
    private var accounts = Set<String>()
    private let calendar = Calendar.current
    private var transactions = [String: Set<Transaction>]()
    
    func add(_ transaction: Transaction) {
        accounts.insert(transaction.accountNumber)
        let tKey = key(for: transaction.date, and: transaction.accountNumber)
        transactions[tKey, default: Set<Transaction>()].insert(transaction)
    }
    
    func getAmount(for date: Date) -> Double {
        return accounts.reduce(0) { result, account in
            let tKey = key(for: date, and: account)
            let daylyAccountTransactionAmount = transactions[tKey]?.reduce(0) { tResult, transaction in
                tResult + transaction.amount
            }
            return result + (daylyAccountTransactionAmount ?? 0.0)
        }
    }
    
    func getTransactions(for date: Date) ->  [Transaction] {
        return transactions.values.flatMap { $0 }.filter { tr in
             calendar.compare(tr.date, to: date, toGranularity: .day) == .orderedSame
        }
    }
    
    private func key(for date: Date, and accountNumber: String) -> String {
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else {
            return "unrecognozed"
        }
        return "\(accountNumber) \(day) \(month) \(year)"
    }
}
