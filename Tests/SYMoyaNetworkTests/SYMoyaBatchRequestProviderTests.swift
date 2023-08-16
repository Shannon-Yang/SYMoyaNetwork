//
//  SYMoyaBatchRequestProviderTests.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/15.
//

import Foundation
import XCTest
@testable import SYMoyaNetwork

class SYMoyaBatchRequestProviderTests: XCTestCase {

    let batch = SYBatchMoyaProvider<GitHub>.init(targets: [.zen,.userDevkapilbansal,.userDevkapilbansalFollowers])
    let batch2 = SYBatchMoyaProvider<GitHub2>.init(targets: [])
    
    override func setUp() {
        let zen = BatchMoyaProvider<GitHub>()
        let userProfile = BatchMoyaProvider(targetType: GitHub.userProfile("Shannon"))
        let post = BatchMoyaProvider(targetType: HTTPBin.post)
        let requestMoyaWebContent = BatchMoyaProvider(targetType: GitHubUserContent.requestMoyaWebContent("logo_github.png"))
        batch = SYMoyaBatchRequestProvider(providers: [zen,userProfile,post,requestMoyaWebContent])
    }
    
    func testBatchRequest() {
        batch.request { (response: BatchDataResponse<Target>) in
            debugPrint("🔥🔥🔥🔥🔥----> \(response) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
        }
    }
}
