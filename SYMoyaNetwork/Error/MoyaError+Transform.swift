//
//  MoyaError+Transform.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/3.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya


public extension MoyaError {
    
    func transformToSYMoyaNetworkError() -> SYMoyaNetworkError {
        
//        switch self {
//        /// Indicates a response failed to map to an image.
//        case imageMapping(let response)
//
//        /// Indicates a response failed to map to a JSON structure.
//        case jsonMapping(let response)
//
//        /// Indicates a response failed to map to a String.
//        case stringMapping(let response)
//
//        /// Indicates a response failed to map to a Decodable object.
//        case objectMapping(let error, let response)
//
//        /// Indicates that Encodable couldn't be encoded into Data
//        case encodableMapping(let error)
//
//        /// Indicates a response failed with an invalid HTTP status code.
//        case statusCode(let response)
//
//        /// Indicates a response failed due to an underlying `Error`.
//        case underlying(let error, let response)
//
//        /// Indicates that an `Endpoint` failed to map to a `URLRequest`.
//        case requestMapping(let string)
//
//        /// Indicates that an `Endpoint` failed to encode the parameters for the `URLRequest`.
//        case parameterEncoding(let error)
//        }
        return .cacheError(reason: .responseNotExisting(key: ""))
    }
    
    
}


