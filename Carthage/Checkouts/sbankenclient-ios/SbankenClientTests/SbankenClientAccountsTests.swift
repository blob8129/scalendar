//
//  SbankenClientTests.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import XCTest
@testable import SbankenClient

class SbankenClientAccountsTests: XCTestCase {
    var mockUrlSession = MockURLSession()
    var mockTokenManager = AccessTokenManager()
    var defaultUserId = "12345"
    var defaultAccessToken = "TOKEN"
    var client: SbankenClient?
    
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
    
    var badAccountData = """
        [tralala
    """.data(using: .utf8)
    
    override func setUp() {
        super.setUp()
        mockTokenManager.token = AccessToken("TOKEN", expiresIn: 1000, tokenType: "TYPE")
        client = SbankenClient(clientId: "CLIENT",
                            secret: "SECRET")
        client?.urlSession = mockUrlSession as SURLSessionProtocol
        client?.tokenManager = mockTokenManager
        mockUrlSession.lastRequest = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClientHasDecoder() {
        XCTAssertNotNil(client?.decoder)
    }
    
    func testSetupSbankenClient() {
        let newClient = SbankenClient(clientId: "CLIENT", secret: "SECRET")
        
        XCTAssertEqual(newClient.clientId, "CLIENT")
        XCTAssertEqual(newClient.secret, "SECRET")
    }
    
    func testClientQueriesForAccounts() {
        let request = accountRequest(userId: defaultUserId)
        
        XCTAssertEqual(request?.url?.path, "/Bank/api/v1/Accounts/\(defaultUserId)")
    }
    
    func testAccountRequestHasRequiredHeaders() {
        let request = accountRequest(userId: defaultUserId)
        
        XCTAssertEqual(request?.allHTTPHeaderFields!["Authorization"], "Bearer \(defaultAccessToken)")
        XCTAssertEqual(request?.allHTTPHeaderFields!["Accept"], "application/json")
    }
    
    func testAccountRequestReturnsNilForInvalidUrl() {
        let request = accountRequest(userId: "|")
        
        XCTAssertNil(request)
    }
    
    func testAccountRequestReturnsErrorForBadData() {
        mockUrlSession.responseData = badAccountData
        let errorExpectation = expectation(description: "Error occurred")
        _ = accountRequest(userId: defaultUserId, success: { _ in }, failure: { (returnedError) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testAccountRequestReturnsSuccessForGoodData() {
        mockUrlSession.responseData = goodAccountData
        let returnExpectation = expectation(description: "Error or success was called")
        _ = accountRequest(userId: defaultUserId, success: { (accounts) in
            XCTAssertNotNil(accounts)
            returnExpectation.fulfill()
        }, failure: { (returnedError) in
            XCTFail("Error should not occur")
            returnExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testAccountRequestDoesNotFail() {
        let errorExpectation = expectation(description: "Error occurred")
        _ = accountRequest(userId: defaultUserId, success: { _ in }, failure: { (returnedError) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testAccountRequestReturnsErrorForHttpError() {
        mockUrlSession.responseError = NSError(domain: "error", code: 0, userInfo: nil)
        let errorExpectation = expectation(description: "Error occurred")
        _ = accountRequest(userId: defaultUserId, success: { _ in }, failure: { (returnedError) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func accountRequest(userId: String, success: @escaping ([Account]) -> Void = {_ in }, failure: @escaping (Error?) -> Void = {_ in }) -> URLRequest? {
        client?.accounts(userId: userId, success: success, failure: failure)
        
        return mockUrlSession.lastRequest
    }
}
