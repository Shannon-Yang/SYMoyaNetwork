//
//  Response+HandyJSON.swift
//  KuaiYin
//
//  Created by ShannonYang on 2021/9/23.
//  Copyright © 2021 Chengdu Happy Music Technology Co., Ltd. All rights reserved.
//

import Foundation
import Moya
import HandyJSON

public extension Response {
    
    func mapObject<T: HandyJSON>(_ type: T.Type) -> T? {
        guard let dataString = String.init(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeFrom(json: dataString)
        else {
            return nil
        }
        return object
    }
    
    func mapObject<T: HandyJSON>(_ type: T.Type, designatedPath: String) -> T? {
        guard let dataString = String(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeFrom(json: dataString, designatedPath: designatedPath)
        else {
            return nil
        }
        return object
    }
    
    func mapArray<T: HandyJSON>(_ type: T.Type)  -> [T?]? {
        guard let dataString = String(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeModelArrayFrom(json: dataString)
        else {
            return nil
        }
        return object
    }
    
    
    func mapArray<T: HandyJSON>(_ type: T.Type, designatedPath: String )  -> [T?]? {
        guard let dataString = String(data: self.data, encoding: .utf8),
              let object = JSONDeserializer<T>.deserializeModelArrayFrom(json: dataString , designatedPath: designatedPath)
        else {
            return nil
        }
        return object
    }
    
}
