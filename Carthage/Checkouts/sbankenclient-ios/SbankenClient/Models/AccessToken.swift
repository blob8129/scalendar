//
//  AccessToken.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 27/11/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class AccessToken: Codable {
    public var accessToken: String
    public var expiresIn: Int
    public var tokenType: String
    
    lazy var expiryDate: Date = {
        return Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())!
    }()
    
    init(_ accessToken: String, expiresIn: Int, tokenType: String) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}
