//
//  File.swift
//  
//
//  Created by ShannonYang on 2021/9/17.
//

import Foundation
import XCTest
@testable import SYMoyaNetwork

class SYMoyaProviderTest: XCTestCase {
    
    override class func tearDown() {
        
    }
    
    override func tearDown() {
        
    }
    
    override func tearDown(completion: @escaping (Error?) -> Void) {
        
    }
    
    override func setUp() {
        
    }
    
    
    func test_fsa_Cofig() {
        NetworkConfig.sharedInstance.logConfiguration = .init()
        addTeardownBlock {
            
        }
    }
}
