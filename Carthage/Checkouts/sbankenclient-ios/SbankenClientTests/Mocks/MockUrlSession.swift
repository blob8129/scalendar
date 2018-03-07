//
//  MockUrlSession.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 12/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation
@testable import SbankenClient

protocol URLSessionDataTaskProtocol {
    func resume()
}

class MockURLSessionDataTask: URLSessionDataTask, URLSessionDataTaskProtocol {
    public var resumeWasCalled = false
    
    override public init() {
        
    }
    
    override public func resume() {
        resumeWasCalled = true
    }
}

class MockURLSession: SURLSessionProtocol {
    var lastRequest: URLRequest?
    var responseData: Data?
    var tokenResponseData: Data? = nil
    var responseError: Error? = nil
    var responseUrlResponse: URLResponse?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        lastRequest = request
        if (request.url?.path == "/identityserver/connect/token") {
            completionHandler(self.tokenResponseData, self.responseUrlResponse, self.responseError)
        } else {
            completionHandler(self.responseData, self.responseUrlResponse, self.responseError)
        }
        return MockURLSessionDataTask()
    }
}
