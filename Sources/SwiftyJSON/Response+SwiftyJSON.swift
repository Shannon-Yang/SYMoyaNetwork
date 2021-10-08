//
//  Response+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

public extension Response {
    
    /// <#Description#>
    /// - Parameter opt: <#opt description#>
    /// - Throws: <#description#>
    /// - Returns: <#description#>
    func mapSwiftyJSON(options opt: JSONSerialization.ReadingOptions = []) throws -> JSON {
        do {
            return try JSON(data: self.data, options: opt)
        } catch _ {
            throw MoyaError.jsonMapping(self)
        }
    }
}
