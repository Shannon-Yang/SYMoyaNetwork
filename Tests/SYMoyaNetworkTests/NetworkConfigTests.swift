//
//  NetworkConfigTests.swift
//  SYMoyaNetworkTests
//
//  Created by Shannon Yang on 2023/7/17.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import XCTest
import Moya
@testable import SYMoyaNetwork

class NetworkConfigTests: XCTestCase {
    
    func testDefaultNetworkConfig() {
        let logConf = NetworkConfig.sharedInstance.logConfiguration
        let cache = NetworkConfig.sharedInstance.networkCache
        XCTAssertEqual(logConf.logOptions, SYMoyaNetworkLoggerPlugin.Configuration.LogOptions.default)
        XCTAssertNotNil(logConf.formatter)
        XCTAssertTrue(logConf.shouldPrintRequestLog)
        XCTAssertNotNil(cache)
    }
    
    func testCustomNetworkConfig() {
        let formatte = SYMoyaNetworkLoggerPlugin.Configuration.Formatter()
        let output = { (target: TargetType, items: [String]) in }
        let logOptions = SYMoyaNetworkLoggerPlugin.Configuration.LogOptions.verbose
        let shouldPrintRequestLog = false
        let logConfig = LogConfiguration(formatter: formatte, output: output, logOptions: logOptions, shouldPrintRequestLog: shouldPrintRequestLog)
        NetworkConfig.sharedInstance.logConfiguration = logConfig
        let cache = NetworkCache(name: "Custom")
        NetworkConfig.sharedInstance.networkCache = cache
        XCTAssertFalse(shouldPrintRequestLog)
        XCTAssertNotNil(NetworkConfig.sharedInstance.logConfiguration)
        XCTAssertIdentical(NetworkConfig.sharedInstance.networkCache, cache)
        XCTAssertEqual(NetworkConfig.sharedInstance.logConfiguration.logOptions, logOptions)
    }
}
