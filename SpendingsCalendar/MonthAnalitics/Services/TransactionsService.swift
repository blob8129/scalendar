//
//  TransactionsService.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/6/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import Foundation
import SbankenClient

protocol TransactionsServiceDelegate: class {
    func didLoadedTransactions()
}

final class TransactionsService {
    private let client = SbankenClient(clientId: clientId, secret: secret)
    private lazy var transactionsManager = TransactionsManager()
    private lazy var transactionsAnalyzer = TransactionsAnalyzer()
    private let dispatchGroup = DispatchGroup()
    
    weak var delegate: TransactionsServiceDelegate?
    var periods: [[Period]] {
        get {
            return transactionsAnalyzer.periods
        }
    }
    var maxSpendingsWeekDay: (weekDay: String, amount: Double)? {
        return transactionsAnalyzer.getMaxSpendingsWeekDay()
    }
    
    var maxSavingsWeekDay: (weekDay: String, amount: Double)? {
        return transactionsAnalyzer.getMaxSavigsWeekDay()
    }
    
    func getPosition(for date: Date) -> RelativePriodPosition {
        return transactionsAnalyzer.getPosition(for: date)
    }
    
    func getTransactionsForAllAcoounts(from start: Date, to end: Date) {
        client.accounts(userId: userId, success: { [weak self] accounts in
            accounts.forEach { account in
                self?.dispatchGroup.enter()
                self?.getTransactions(for: account.accountNumber, from: start, to: end) {
                    self?.dispatchGroup.leave()
                }
            }
            self?.dispatchGroup.notify(queue: .main) {
                self?.delegate?.didLoadedTransactions()
            }
        }) { error in
            print("An accounts error occurred \(error.debugDescription)")
        }
    }
    
    func getAmount(for date: Date) -> Double {
        return transactionsManager.getAmount(for: date)
    }
    
    func getTransactions(for date: Date) -> [Transaction] {
        return transactionsManager.getTransactions(for: date)
    }
    
    private func getTransactions(for accountNumber: String, from start: Date, to end: Date, callback: @escaping () -> Void) {
        client.transactions(userId: userId, accountNumber: accountNumber,
                            startDate: start, endDate: end, length: 100,
                            success: {[unowned self] response in
                                
                                print("Count \(response.items.count)")
                                
                                response.items.forEach { transaction in
                                    
                                    if let accountingDate = transaction.accountingDate {
                                        
                                        let transaction = Transaction(id: transaction.transactionId,
                                                                      amount: transaction.amount,
                                                                      date: accountingDate,
                                                                      accountNumber: transaction.accountNumber,
                                                                      type: transaction.transactionType)
                                        self.transactionsManager.add(transaction)
                                        
                                    }
                                }
                                
                                self.transactionsAnalyzer.analyzeTransactions(for: start, to: end, using: self.transactionsManager)
                                callback()

            }, failure: { _ in
                callback()
                print("An transactions error occurred")
        })
    }
}
