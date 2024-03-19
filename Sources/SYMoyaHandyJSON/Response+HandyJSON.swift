//
//  Response+HandyJSON.swift
//  KuaiYin
//
//  Created by Shannon Yang on 2021/9/23.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import HandyJSON

//MARK: - HandyJSON
extension Response {
    /// Convert response to HandyJSON format data
    ///
    /// - Parameters:
    ///   - type: A generic object implementing HandyJSON
    /// - Returns: The converted HandyJSON data
    func mapObject<T: HandyJSON>(_ type: T.Type) -> T? {
        guard let dataString = String.init(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeFrom(json: dataString)
        else {
            return nil
        }
        return object
    }
    
    /// Convert response to HandyJSON format data
    ///
    /// - Parameters:
    ///   - type: A generic object implementing HandyJSON
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    /// - Returns: The converted HandyJSON data
    func mapObject<T: HandyJSON>(_ type: T.Type, designatedPath: String) -> T? {
        guard let dataString = String(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeFrom(json: dataString, designatedPath: designatedPath)
        else {
            return nil
        }
        return object
    }
    
    /// Convert response to HandyJSON array format data
    ///
    /// - Parameters:
    ///   - type: A generic object implementing HandyJSON
    /// - Returns: The converted HandyJSON data array
    func mapArray<T: HandyJSON>(_ type: T.Type)  -> [T?]? {
        guard let dataString = String(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeModelArrayFrom(json: dataString)
        else {
            return nil
        }
        return object
    }
    
    /// Convert response to HandyJSON format data array
    ///
    /// - Parameters:
    ///   - type: A generic object implementing HandyJSON
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    /// - Returns: The converted HandyJSON data array
    func mapArray<T: HandyJSON>(_ type: T.Type, designatedPath: String)  -> [T?]? {
        guard let dataString = String(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeModelArrayFrom(json: dataString , designatedPath: designatedPath)
        else {
            return nil
        }
        return object
    }
    
}
