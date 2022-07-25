//
//  Response+MJExtension.swift.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/1/4.
//  Copyright © 2022 Shenzhen JUJUBE Health Technology Co.,Ltd. All rights reserved.
//

import Foundation
import Moya
import MJExtension

//MARK: - MJExtension
public extension Response {
    
    /// Convert response to MJExtension format data
    /// - Parameters:
    ///   - type: Subclass object that inherits NSObject
    /// - Returns: The converted MJExtension data
    func mapObject<T: NSObject>(_ type: T.Type) -> T? {
        return type.mj_object(withKeyValues: self.data)
    }

    /// Convert response to MJExtension format data array
    /// - Parameters:
    ///   - type: Subclass object that inherits NSObject
    /// - Returns: The converted MJExtension data array
    func mapArray<T: NSObject>(_ type: T.Type)  -> [T]? {
        return type.mj_objectArray(withKeyValuesArray: self.data) as? [T]
    }
    
}
