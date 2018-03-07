//
//  Account.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class Account: Codable {
    public let accountNumber: String
    public let customerId: String
    public let ownerCustomerId: String
    public let name: String
    public let accountType: String
    public let available: Double
    public let balance: Double
    public let creditLimit: Double
    public let defaultAccount: Bool
}
