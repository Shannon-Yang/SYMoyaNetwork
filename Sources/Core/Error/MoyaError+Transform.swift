//
//  MoyaError+Transform.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/9/3.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public extension MoyaError {
    
    /// <#Description#>
    /// - Returns: <#description#>
    func transformToSYMoyaNetworkError() -> SYMoyaNetworkError {
        switch self {
        /// Indicates a response failed to map to an image.
        case .imageMapping(let response):
            return .serializeError(reason: .imageMapping(response: response))
        /// Indicates a response failed to map to a JSON structure.
        case .jsonMapping(let response):
            return .serializeError(reason: .jsonMapping(response: response))
        /// Indicates a response failed to map to a String.
        case .stringMapping(let response):
            return .serializeError(reason: .stringMapping(response: response))
        /// Indicates a response failed to map to a Decodable object.
        case .objectMapping(let error, let response):
            return .serializeError(reason: .objectMapping(error: error, response: response))
        /// Indicates that Encodable couldn't be encoded into Data
        case .encodableMapping(let error):
            return .serializeError(reason: .encodableMapping(error: error))
        /// Indicates a response failed with an invalid HTTP status code.
        case .statusCode(let response):
            return .validationErrorReason(reason: .statusCode(response: response))
        /// Indicates a response failed due to an underlying `Error`.
        case .underlying(let error, let response):
            return .requestErrorReason(reason: .underlying(error: error, response: response))
        /// Indicates that an `Endpoint` failed to map to a `URLRequest`.
        case .requestMapping(let string):
            return .endpointErrorReason(reason: .urlRequestCreateFail(string: string))
        /// Indicates that an `Endpoint` failed to encode the parameters for the `URLRequest`.
        case .parameterEncoding(let error):
            return .endpointErrorReason(reason: .parameterEncodingError(error: error))
        }
    }
}

