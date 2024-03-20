//
//  StringResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2024/3/20.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

/// A `ResponseSerializer` that decodes the response data as a `String`.
public class StringResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = String
    private let atKeyPath: String?
    
    /// Init StringResponseSerializer
    ///
    /// - Parameter atKeyPath: Optional key path at which to parse string.
    public init(atKeyPath: String? = nil) {
        self.atKeyPath = atKeyPath
    }
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<String>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerStringDataResponse(atKeyPath: atKeyPath)
    }
}

public extension ResponseSerializer where Self == StringResponseSerializer {
    /// Default serializer object
    static var defaultStringSerializer: StringResponseSerializer {
        StringResponseSerializer()
    }
    
    /// Create a StringResponseSerializer
    ///
    /// - Parameter atKeyPath: Optional key path at which to parse string.
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `String`.
    static func string(atKeyPath: String?) -> StringResponseSerializer {
        return StringResponseSerializer(atKeyPath: atKeyPath)
    }
}
