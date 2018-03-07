//
//  TransferRequest.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 27/11/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public struct TransferRequest: Codable {
    public var fromAccount: String
    public var toAccount: String
    public var message: String
    public var amount: Float
}
