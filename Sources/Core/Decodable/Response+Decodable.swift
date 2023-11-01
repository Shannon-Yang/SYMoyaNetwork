//
//  Response+Codable.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - Codable
extension Response {
    /// Convert response to Codable format data
    /// - Parameters:
    ///   - keyPath: Optional key path at which to parse string.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: The converted codable data
    func mapCodableObject<T: Decodable>(atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> T {
        do {
            return try map(T.self, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
        } catch let moyaError as MoyaError {
            throw moyaError
        } catch {
            throw MoyaError.underlying(error, self)
        }
    }
}
