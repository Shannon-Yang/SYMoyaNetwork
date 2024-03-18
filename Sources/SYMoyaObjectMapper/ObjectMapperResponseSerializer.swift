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

public class ObjectMapperObjectResponseSerializer<T: BaseMappable>: ResponseSerializer {
    public typealias SerializedObject = T
    
    private let keyPath: String?
    private let context: MapContext?
    init(keyPath: String? = nil, context: MapContext? = nil) {
        self.keyPath = keyPath
        self.context = context
    }

    public func serialize(result: SYMoyaNetwork.SYMoyaNetworkResult) -> SYMoyaNetwork.SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerMapperObjectDataResponse(keyPath: keyPath, context: context)
    }
    
    public static var defaultMapperObjectSerializer: ObjectMapperObjectResponseSerializer<SerializedObject> {
        ObjectMapperObjectResponseSerializer<SerializedObject>()
    }
}

public extension ResponseSerializer {
    static func mapperObject<T: BaseMappable>(keyPath: String? = nil, context: MapContext? = nil) -> ObjectMapperObjectResponseSerializer<T> {
        return ObjectMapperObjectResponseSerializer<T>(keyPath: keyPath, context: context)
    }
}

public class ObjectMapperObjectsResponseSerializer<T: BaseMappable>: ResponseSerializer {
    public typealias SerializedObject = [T]
    private let keyPath: String?
    private let context: MapContext?
    init(keyPath: String? = nil, context: MapContext? = nil) {
        self.keyPath = keyPath
        self.context = context
    }
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerMapperObjectsDataResponse(keyPath: keyPath, context: context)
    }
    
    public static var defaultMapperObjectsSerializer: ObjectMapperObjectsResponseSerializer<T> {
        ObjectMapperObjectsResponseSerializer<T>()
    }
}

public extension ResponseSerializer {
    static func mapperObjects<T: BaseMappable>(keyPath: String? = nil, context: MapContext? = nil) -> ObjectMapperObjectsResponseSerializer<T> {
        return ObjectMapperObjectsResponseSerializer<T>(keyPath: keyPath, context: context)
    }
}

