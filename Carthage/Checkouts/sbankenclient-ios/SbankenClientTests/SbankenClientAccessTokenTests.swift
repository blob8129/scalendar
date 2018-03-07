//
//  SbankenClientTests.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import XCTest
@testable import SbankenClient

class SbankenClientAccessTokenTests: XCTestCase {
    var mockUrlSession = MockURLSession()
    var tokenManager = AccessTokenManager()
    var defaultUserId = "12345"
    var defaultAccountNumber = "97100000000"
    var defaultAccessToken = "TOKEN"
    var client: SbankenClient?
    
    var goodAccessTokenData = """
        {
        "token": "TOKEN",
        "expires_in": 12345,
        "token_type": "TYPE"
        }
    """.data(using: .utf8)
    
    var badAccessTokenData = """
        [tralala
    """.data(using: .utf8)
    
    var goodAccountData = """
        {
            "availableItems": 1,
            "items":
            [{
            "accountNumber": "12345678901",
            "customerId": "12345",
            "ownerCustomerId": "12345",
            "name": "Generell konto",
            "accountType": "Konto",
            "available": 100.0,
            "balance": 1200.0,
            "creditLimit": 500.0,
            "defaultAccount": true
            }]
        }
    """.data(using: .utf8)
    
    override func setUp() {
        super.setUp()
        client = SbankenClient(clientId: "CLIENT",
                            secret: "SECRET")
        client?.urlSession = mockUrlSession as SURLSessionProtocol
        client?.tokenManager = tokenManager
        mockUrlSession.lastRequest = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetupSbankenClient() {
        let newClient = SbankenClient(clientId: "CLIENT", secret: "SECRET")
        
        XCTAssertEqual(newClient.clientId, "CLIENT")
        XCTAssertEqual(newClient.secret, "SECRET")
    }
    
    func testAccountsGetsTokenFromManager() {
        _ = client?.accounts(userId: defaultUserId, success: { _ in }, failure: { _ in })
        let request = mockUrlSession.lastRequest
        XCTAssertEqual(request?.url?.path, "/identityserver/connect/token")
        XCTAssertEqual(request?.httpMethod, "POST")
    }
    
    func testTokenRequestReturnsErrorForBadData() {
        mockUrlSession.tokenResponseData = badAccessTokenData
        let errorExpectation = expectation(description: "Error occurred")
        _ = client?.accounts(userId: defaultUserId, success: { _ in }, failure: { _ in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testNilTokenForAccountsReturnsError() {
        client?.tokenManager.token = AccessToken("TOKEN", expiresIn: -1000, tokenType: "TYPE")
        var error = false
        _ = client?.accounts(userId: defaultUserId,
                             success: { _ in },
                             failure: { _ in error = true })
        
        XCTAssertTrue(error)
    }
    
    func testNilTokenForTransactionsReturnsError() {
        client?.tokenManager.token = AccessToken("TOKEN", expiresIn: -1000, tokenType: "TYPE")
        var error = false
        _ = client?.transactions(userId: defaultUserId,
                                 accountNumber: "97100000000",
                                 startDate: Date(),
                                 endDate: Date(),
                                 index: 0,
                                 length: 10,
                                 success: { _ in },
                                 failure: { _ in error = true })
        
        XCTAssertTrue(error)
    }
    
    
    
    func testTokenRequestReturnsSuccessForGoodData() {
        mockUrlSession.tokenResponseData = goodAccessTokenData
        mockUrlSession.responseData = goodAccountData
        var error = false
        _ = client?.accounts(userId: defaultUserId, success: { _ in }, failure: { _ in
            error = true
        })
        
        XCTAssertFalse(error)
    }

}
