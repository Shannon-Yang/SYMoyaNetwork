//
//  SYMoyaBatchRequestTests.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/15.
//

import Foundation
import XCTest
@testable import SYMoyaNetwork

class SYMoyaBatchRequestProviderTests: XCTestCase {
    
    var session: SYMoyaBatchProviderSession?

    override func setUp() {
        let provider = SYMoyaBatchProvider<HTTPBinDynamicData>(targetTypes: [.getDelay(delay: 1),.stream(n: 1)])
        let provider2 = SYMoyaBatchProvider<HTTPBinResponseFormats>(targetTypes: [.brotli,.json,.gzipped])
        self.session = SYMoyaBatchProviderSession(providers: [provider,provider2])
    }
    
    func testBatchRequest() {
        self.session?.request(progressCompletion: { progress in
            debugPrint("🔥🔥🔥🔥🔥----> \(progress) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
        }, completion: { result in
            debugPrint("🔥🔥🔥🔥🔥----> \(result) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
        })
        
        waitForExpectations(timeout: 10)
    }
}
