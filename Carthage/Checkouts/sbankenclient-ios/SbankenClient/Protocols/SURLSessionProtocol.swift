//
//  SURLSession.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 13/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public protocol SURLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: SURLSessionProtocol { }
