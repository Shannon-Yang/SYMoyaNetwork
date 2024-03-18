//
//  File.swift
//  
//
//  Created by Shannon Yang on 2021/9/17.
//  Copyright © 2023 Shannon Yang. All rights reserved.
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
