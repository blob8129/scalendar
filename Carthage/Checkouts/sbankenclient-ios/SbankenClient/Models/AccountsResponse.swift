//
//  AccountsResponse.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 27/11/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public struct AccountsResponse : Codable {
    public var availableItems: Int
    public var items: [Account]
}
