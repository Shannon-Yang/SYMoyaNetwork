//
//  Response+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/19.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

// MARK: - Response SwiftyJSON

extension Response {
    /// Convert response to SwiftlyJSON format data
    ///
    /// - Parameter opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    /// - Throws: If the conversion fails, a JSON parsing failure error will be thrown
    /// - Returns: The converted json data
    public func mapSwiftyJSON(options opt: JSONSerialization.ReadingOptions = []) throws -> JSON {
        do {
            return try JSON(data: data, options: opt)
        } catch _ {
            throw MoyaError.jsonMapping(self)
        }
    }
}
