//
//  DecodableResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2024/3/20.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

/// A `ResponseSerializer` that decodes the response data as a `Decodable`.
public class DecodableResponseSerializer<T: Decodable>: ResponseSerializer {
    public typealias SerializedObject = T
    private let keyPath: String?
    private let decoder: JSONDecoder
    private let failsOnEmptyData: Bool

    /// Init DecodableResponseSerializer
    ///
    /// - Parameters:
    ///   - keyPath: Optional key path at which to parse string.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    public init(atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) {
        self.keyPath = keyPath
        self.decoder = decoder
        self.failsOnEmptyData = failsOnEmptyData
    }

    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<Decodable>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `Decodable`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }

    /// Default serializer object
    public static var defaultDecodableSerializer: DecodableResponseSerializer<SerializedObject> {
        DecodableResponseSerializer<SerializedObject>()
    }
}

extension ResponseSerializer {
    /// Create a DecodableResponseSerializer
    ///
    /// - Parameters:
    ///   - keyPath: Optional key path at which to parse string.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `Decodable`.
    public static func decodable<T: Decodable>(atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> DecodableResponseSerializer<T> {
        DecodableResponseSerializer<T>(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
}
