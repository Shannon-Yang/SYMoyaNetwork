//
//  MoyaError+Transform.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/9/3.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension MoyaError {
    /// Convert to SYMoyaNetworkError
    /// - Returns: Represents all the errors which can happen in SYMoyaNetwork framework.
    public func transformToSYMoyaNetworkError() -> SYMoyaNetworkError {
        switch self {
        case let .imageMapping(response):
            // Indicates a response failed to map to an image.
            return .serializeError(reason: .imageMapping(response: response))
        case let .jsonMapping(response):
            // Indicates a response failed to map to a JSON structure.
            return .serializeError(reason: .jsonMapping(response: response))
        case let .stringMapping(response):
            // Indicates a response failed to map to a String.
            return .serializeError(reason: .stringMapping(response: response))
        case let .objectMapping(error, response):
            // Indicates a response failed to map to a Decodable object.
            return .serializeError(reason: .objectMapping(error: error, response: response))
        case let .encodableMapping(error):
            // Indicates that Encodable couldn't be encoded into Data
            return .serializeError(reason: .encodableMapping(error: error))
        case let .statusCode(response):
            // Indicates a response failed with an invalid HTTP status code.
            return .validationErrorReason(reason: .statusCode(response: response))
        case let .underlying(error, response):
            // Indicates a response failed due to an underlying `Error`.
            return .requestErrorReason(reason: .underlying(error: error, response: response))
        case let .requestMapping(string):
            // Indicates that an `Endpoint` failed to map to a `URLRequest`.
            return .endpointErrorReason(reason: .urlRequestCreateFail(string: string))
        case let .parameterEncoding(error):
            // Indicates that an `Endpoint` failed to encode the parameters for the `URLRequest`.
            return .endpointErrorReason(reason: .parameterEncodingError(error: error))
        }
    }
}
