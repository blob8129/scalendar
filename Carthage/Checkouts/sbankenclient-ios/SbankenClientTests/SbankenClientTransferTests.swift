//
//  SbankenClientTests.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import XCTest
@testable import SbankenClient

class SbankenClientTransferTests: XCTestCase {
    var mockUrlSession = MockURLSession()
    var mockTokenManager = AccessTokenManager()
    var defaultUserId = "12345"
    var defaultAccessToken = "TOKEN"
    var client: SbankenClient?
    
    var goodTransferResponseData = """
        {
            "isError": false,
        }
    """.data(using: .utf8)
    
    var errorTransferResponseData = """
        {
            "isError": true,
        }
    """.data(using: .utf8)
    
    var badTransferResponseData = """
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
    
    func testClientQueriesForTransfer() {
        let request = transferRequest(userId: defaultUserId)
        
        XCTAssertEqual(request?.url?.path, "/Bank/api/v1/Transfers/\(defaultUserId)")
    }
    
    func testTransferRequestHasRequiredHeaders() {
        let request = transferRequest(userId: defaultUserId)
        
        XCTAssertEqual(request?.allHTTPHeaderFields!["Authorization"], "Bearer \(defaultAccessToken)")
        XCTAssertEqual(request?.allHTTPHeaderFields!["Accept"], "application/json")
    }
    
    func testTransferRequestReturnsNilForInvalidUrl() {
        let request = transferRequest(userId: "|")
        
        XCTAssertNil(request)
    }
    
    func testTransferRequestReturnsErrorForBadData() {
        mockUrlSession.responseData = badTransferResponseData
        let errorExpectation = expectation(description: "Error occurred")
        _ = transferRequest(userId: defaultUserId, success: { _ in }, failure: { (returnedError) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testTransferRequestReturnsErrorForErrorResponse() {
        mockUrlSession.responseData = errorTransferResponseData
        let errorExpectation = expectation(description: "Error occurred")
        _ = transferRequest(userId: defaultUserId, success: { _ in }, failure: { (returnedError) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testTransferRequestReturnsSuccessForGoodData() {
        mockUrlSession.responseData = goodTransferResponseData
        let returnExpectation = expectation(description: "Error or success was called")
        _ = transferRequest(userId: defaultUserId, success: { (response) in
            XCTAssertNotNil(response)
            returnExpectation.fulfill()
        }, failure: { (returnedError) in
            XCTFail("Error should not occur")
            returnExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testTransferRequestDoesNotFail() {
        let errorExpectation = expectation(description: "Error occurred")
        _ = transferRequest(userId: defaultUserId, success: { _ in }, failure: { (returnedError) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testTransferRequestReturnsErrorForHttpError() {
        mockUrlSession.responseError = NSError(domain: "error", code: 0, userInfo: nil)
        let errorExpectation = expectation(description: "Error occurred")
        _ = transferRequest(userId: defaultUserId, success: { _ in }, failure: { (returnedError) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func transferRequest(userId: String, fromAccount: String = "1234", toAccount: String = "5678",
                         message: String = "MESSAGE", amount: Float = 10.0,
                         success: @escaping (TransferResponse) -> Void = {_ in },
                         failure: @escaping (Error?) -> Void = {_ in }) -> URLRequest? {
        client?.transfer(userId: userId,
                         fromAccount: fromAccount,
                         toAccount: toAccount,
                         message: message,
                         amount: amount,
                         success: success,
                         failure: failure)
        
        return mockUrlSession.lastRequest
    }
}

