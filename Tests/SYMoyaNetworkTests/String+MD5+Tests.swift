//
//  String+MD5+Tests.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/15.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import XCTest
@testable import SYMoyaNetwork

class StringMD5Tests: XCTestCase {
    func testStringMD5() {
        let s = "hello"
        XCTAssertEqual(s.md5(), "5d41402abc4b2a76b9719d911017c592")
    }
}

