//
//  Double+shortDisplayValueTests.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 10/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

import XCTest
@testable import SbankenClient

class DoubleShortDisplayValueTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testReturnsFullValueUpToThousand() {
        let number: Double = 999.9
        XCTAssertEqual(number.shortDisplayValue(), "999.9")
    }
    
    func testReturnsAbbreviatedValueAboveThousand() {
        let number: Double = 1001.0
        XCTAssertEqual(number.shortDisplayValue(), "1.0k")
    }
    
    func testReturnsAbbreviatedValueAboveTenThousand() {
        let number: Double = 10001.0
        XCTAssertEqual(number.shortDisplayValue(), "10.0k")
    }
    
    func testReturnsFullValueAboveHundredThousand() {
        let number: Double = 100001.0
        XCTAssertEqual(number.shortDisplayValue(), "100001.0")
    }
    
    func testReturnsFullNegativeValue() {
        let number: Double = -1001.0
        XCTAssertEqual(number.shortDisplayValue(), "-1001.0")
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
