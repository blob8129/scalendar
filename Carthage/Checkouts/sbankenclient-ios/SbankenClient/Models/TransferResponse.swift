//
//  TransferResponse.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 27/11/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public struct TransferResponse: Codable {
    public var errorType: String?
    public var isError: Bool
    public var errorMessage: String?
}
