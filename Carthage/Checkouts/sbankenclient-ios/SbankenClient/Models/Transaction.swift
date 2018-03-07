//
//  Transaction.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class Transaction: Codable {
    public let transactionId: String
    public let customerId: String
    public let accountNumber: String
    public let otherAccountNumber: String?
    public let amount: Double
    public let text: String
    public let transactionType: String
    public let registrationDate: Date?
    public let accountingDate: Date?
}
