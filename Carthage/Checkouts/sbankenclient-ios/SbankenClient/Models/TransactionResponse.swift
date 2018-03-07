//
//  TransactionResponse.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 10/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public struct TransactionResponse: Codable {
    public var availableItems: Int
    public var items: [Transaction]
}
