//
//  Response+Codable.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension Response {
    
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
