//
//  AccessTokenManager.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 09/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class AccessTokenManager {
    private var _token: AccessToken?
    
    public init() { }
    
    var token: AccessToken? {
        get {
            if (_token != nil && _token!.expiryDate < Date()) {
                _token = nil
            }
            
            return _token
        }
        set(token) {
            _token = token
        }
    }
}
