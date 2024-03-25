//
//  JSONResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2024/3/20.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

/// A `ResponseSerializer` that decodes the response data as a `JSON`.
public class JSONResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = Any
    private let failsOnEmptyData: Bool

    /// Init JSONResponseSerializer
    /// - Parameter failsOnEmptyData: A Boolean value determining
    public init(failsOnEmptyData: Bool = true) {
        self.failsOnEmptyData = failsOnEmptyData
    }

    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<JSON>`
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        result.serializerJSONDataResponse(failsOnEmptyData: failsOnEmptyData)
    }
}

extension ResponseSerializer where Self == JSONResponseSerializer {
    /// Default serializer object
    public static var defaultJSONSerializer: JSONResponseSerializer {
        JSONResponseSerializer()
    }

    /// Create a JSONResponseSerializer
    ///
    /// - Parameter failsOnEmptyData: A Boolean value determining
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `JSON`.
    public static func json(failsOnEmptyData: Bool) -> JSONResponseSerializer {
        JSONResponseSerializer(failsOnEmptyData: failsOnEmptyData)
    }
}
