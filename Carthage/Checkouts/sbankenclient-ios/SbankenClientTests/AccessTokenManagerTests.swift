//
//  AccessTokenManagerTests.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 09/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

import XCTest
@testable import SbankenClient

class AccessTokenManagerTests: XCTestCase {
    lazy var manager: AccessTokenManager = {
        return AccessTokenManager()
    }()
    
    let oneWeek = 60 * 60 * 24 * 7
    
    override func setUp() {
        super.setUp()
    }
    
    func testManagerReturnsEmptyTokenByDefault() {
        assert(manager.token == nil)
    }
    
    func testManagerReturnsTokenWithFutureExpiry() {
        manager.token = AccessToken("TOKEN", expiresIn: 1000, tokenType: "TYPE")
        assert(manager.token?.accessToken == "TOKEN")
    }
    
    func testManagerReturnsEmptyTokenPastExpiry() {
        manager.token = AccessToken("TOKEN", expiresIn: -1000, tokenType: "TYPE")
        assert(manager.token == nil)
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

