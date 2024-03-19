//
//  ObjectMapperResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/27.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import ObjectMapper
import SYMoyaNetwork
//MARK: - ObjectMapperObject
public class ObjectMapperObjectResponseSerializer<T: BaseMappable>: ResponseSerializer {
    public typealias SerializedObject = T
    
    private let keyPath: String?
    private let context: MapContext?
    
    /// Init ObjectMapperObjectResponseSerializer
    ///
    /// - Parameters:
    ///   - keyPath: A specific map path
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    init(keyPath: String? = nil, context: MapContext? = nil) {
        self.keyPath = keyPath
        self.context = context
    }
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<SerializedObject>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value imp `BaseMappable`
    public func serialize(result: SYMoyaNetwork.SYMoyaNetworkResult) -> SYMoyaNetwork.SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerMapperObjectDataResponse(keyPath: keyPath, context: context)
    }

    /// Default serializer object
    public static var defaultMapperObjectSerializer: ObjectMapperObjectResponseSerializer<SerializedObject> {
        ObjectMapperObjectResponseSerializer<SerializedObject>()
    }
}

public extension ResponseSerializer {
    /// Create a default ObjectMapperObjectResponseSerializer
    ///
    /// - Parameters:
    ///   - keyPath: A specific map path
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `ObjectMapperObjectResponseSerializer<T>`.
    static func mapperObject<T: BaseMappable>(keyPath: String? = nil, context: MapContext? = nil) -> ObjectMapperObjectResponseSerializer<T> {
        return ObjectMapperObjectResponseSerializer<T>(keyPath: keyPath, context: context)
    }
}

//MARK: - ObjectMapperObjects
public class ObjectMapperObjectsResponseSerializer<T: BaseMappable>: ResponseSerializer {
    public typealias SerializedObject = [T]
    private let keyPath: String?
    private let context: MapContext?
    
    /// Init ObjectMapperObjectsResponseSerializer
    ///
    /// - Parameters:
    ///   - keyPath: A specific map path
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    init(keyPath: String? = nil, context: MapContext? = nil) {
        self.keyPath = keyPath
        self.context = context
    }
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<[SerializedObject]>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `SYMoyaNetworkDataResponse<[BaseMappable]>`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerMapperObjectsDataResponse(keyPath: keyPath, context: context)
    }
    
    /// Default serializer object
    public static var defaultMapperObjectsSerializer: ObjectMapperObjectsResponseSerializer<T> {
        ObjectMapperObjectsResponseSerializer<T>()
    }
}

public extension ResponseSerializer {
    /// Create a default ObjectMapperObjectsResponseSerializer
    ///
    /// - Parameters:
    ///   - keyPath: A specific map path
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `ObjectMapperObjectsResponseSerializer<T>`.
    static func mapperObjects<T: BaseMappable>(keyPath: String? = nil, context: MapContext? = nil) -> ObjectMapperObjectsResponseSerializer<T> {
        return ObjectMapperObjectsResponseSerializer<T>(keyPath: keyPath, context: context)
    }
}

