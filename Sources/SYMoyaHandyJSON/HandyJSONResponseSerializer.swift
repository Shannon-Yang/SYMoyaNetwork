//
//  HandyJSONResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/25.
//

import Foundation
import HandyJSON
import SYMoyaNetwork

public class HandyJSONObjectResponseSerializer<T: HandyJSON>: ResponseSerializer {
    public typealias SerializedObject = T
    
    private let designatedPath: String?
    public init(designatedPath: String? = nil) {
        self.designatedPath = designatedPath
    }
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerHandyJSONObjectDataResponse(designatedPath: self.designatedPath)
    }
    
    public static var defaultHandyJSONObjectSerializer: HandyJSONObjectResponseSerializer<SerializedObject> {
        HandyJSONObjectResponseSerializer<SerializedObject>()
    }
}

public extension ResponseSerializer {
    static func handyJSONObject<T: HandyJSON>(designatedPath: String? = nil) -> HandyJSONObjectResponseSerializer<T> {
        return HandyJSONObjectResponseSerializer<T>(designatedPath: designatedPath)
    }
}

public class HandyJSONObjectsResponseSerializer<T: HandyJSON>: ResponseSerializer {
    public typealias SerializedObject = [T?]
    private let designatedPath: String?
    public init(designatedPath: String? = nil) {
        self.designatedPath = designatedPath
    }
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerHandyJSONObjectsDataResponse(designatedPath: self.designatedPath)
    }
    
    public static var defaultHandyJSONObjectsSerializer: HandyJSONObjectsResponseSerializer<T> {
        HandyJSONObjectsResponseSerializer<T>()
    }
}

public extension ResponseSerializer {
    static func handyJSONObjects<T: HandyJSON>(designatedPath: String? = nil) -> HandyJSONObjectsResponseSerializer<T> {
        return HandyJSONObjectsResponseSerializer<T>(designatedPath: designatedPath)
    }
}

