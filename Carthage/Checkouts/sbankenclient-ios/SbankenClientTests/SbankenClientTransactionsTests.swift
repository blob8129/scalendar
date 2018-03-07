//
//  SbankenClientTests.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import XCTest
@testable import SbankenClient

class SbankenClientTransactionsTests: XCTestCase {
    var mockUrlSession = MockURLSession()
    var mockTokenManager = AccessTokenManager()
    var defaultUserId = "12345"
    var defaultAccountNumber = "97100000000"
    var defaultAccessToken: AccessToken = AccessToken("TOKEN", expiresIn: 1000, tokenType: "TYPE")
    var client: SbankenClient?
    
    var goodTransactionsData = """
    {
    "availableItems": 22,
    "items": [{
                "transactionId": "1001",
                "customerId": "12345678901",
                "accountNumber": "97100000000",
                "otherAccountNumber": null,
                "amount": -104.520,
                "text": "Varekjøp",
                "transactionType": "Varekjøp",
                "registrationDate": null,
                "accountingDate": "2017-10-14T00:00:00+02:00"
            }, {
                "transactionId": "1002",
                "customerId": "12345678901",
                "accountNumber": "97100000000",
                "otherAccountNumber": null,
                "amount": -122.350,
                "text": "VISA",
                "transactionType": "Bekreftet VISA",
                "registrationDate": null,
                "accountingDate": "2017-10-14T00:00:00+02:00"
            }]
    }
    """.data(using: .utf8)
    
    var badTransactionsData = """
        {tralala
    """.data(using: .utf8)
    
    override func setUp() {
        super.setUp()
        mockTokenManager.token = defaultAccessToken
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
    
    func testClientQueriesForTransactions() {
        let request = transactionRequest(userId: defaultUserId, accountNumber: defaultAccountNumber)
        
        XCTAssertEqual(request?.url?.path, "/Bank/api/v1/Transactions/\(defaultUserId)/\(defaultAccountNumber)")
    }
    
    func testTransactionRequestHasRequiredHeaders() {
        let request = transactionRequest(userId: defaultUserId, accountNumber: defaultAccountNumber)
        
        XCTAssertEqual(request?.allHTTPHeaderFields!["Authorization"], "Bearer \(defaultAccessToken.accessToken)")
        XCTAssertEqual(request?.allHTTPHeaderFields!["Accept"], "application/json")
    }
    
    
    
    func testTransactionRequestReturnsNilForInvalidUrl() {
        let request = transactionRequest(userId: "|", accountNumber: defaultAccountNumber)
        
        XCTAssertNil(request)
    }
    
    
    func testTransactionRequestReturnsErrorForBadData() {
        mockUrlSession.responseData = badTransactionsData
        var error = false
        _ = transactionRequest(userId: defaultUserId,
                               accountNumber: defaultAccountNumber,
                               success: { _ in },
                               failure: { (returnedError) in error = true })
        
        XCTAssertTrue(error)
    }
    
    func testAccountRequestReturnsSuccessForGoodData() {
        mockUrlSession.responseData = goodTransactionsData
        var response: TransactionResponse?
        var error = false
        _ = transactionRequest(userId: defaultUserId,
                               accountNumber: defaultAccountNumber,
                               success: { (transactionResponse) in response = transactionResponse },
                               failure: { (returnedError) in error = true })
        
        XCTAssertFalse(error)
        XCTAssertNotNil(response)
    }
    
    func testAccountRequestReturnsErrorForHttpError() {
        mockUrlSession.responseError = NSError(domain: "error", code: 0, userInfo: nil)
        var error: Error?
        _ = transactionRequest(userId: defaultUserId,
                               accountNumber: defaultAccountNumber,
                               success: { _ in },
                               failure: { (returnedError) in error = returnedError })
        
        XCTAssertNotNil(error)
    }
    
    func transactionRequest(userId: String,
                            accountNumber: String,
                            success: @escaping (TransactionResponse) -> Void = {_ in },
                            failure: @escaping (Error?) -> Void = {_ in }) -> URLRequest? {
        client?.transactions(userId: userId, accountNumber: "97100000000", startDate: Date(), endDate: Date(), index: 0, length: 10, success: { (transactionResponse) in
            success(transactionResponse)
        }, failure: { (error) in
            failure(error)
        })
        
        return mockUrlSession.lastRequest
    }
 
}
