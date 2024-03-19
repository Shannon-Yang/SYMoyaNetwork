//
//  HandyJSONResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/25.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import HandyJSON
import SYMoyaNetwork

//MARK: - HandyJSONObjectResponseSerializer
public class HandyJSONObjectResponseSerializer<T: HandyJSON>: ResponseSerializer {
    public typealias SerializedObject = T
    private let designatedPath: String?
    
    /// Init HandyJSONObjectResponseSerializer
    ///
    /// - Parameter designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    public init(designatedPath: String? = nil) {
        self.designatedPath = designatedPath
    }
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<SerializedObject>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value imp `HandyJSON`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerHandyJSONObjectDataResponse(designatedPath: self.designatedPath)
    }

    /// Default serializer object
    public static var defaultHandyJSONObjectSerializer: HandyJSONObjectResponseSerializer<SerializedObject> {
        HandyJSONObjectResponseSerializer<SerializedObject>()
    }
}

public extension ResponseSerializer {
    /// Create a HandyJSONObjectResponseSerializer
    ///
    /// - Parameter designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `HandyJSONObjectResponseSerializer<T>`.
    static func handyJSONObject<T: HandyJSON>(designatedPath: String? = nil) -> HandyJSONObjectResponseSerializer<T> {
        return HandyJSONObjectResponseSerializer<T>(designatedPath: designatedPath)
    }
}

//MARK: - HandyJSONObjectsResponseSerializer
public class HandyJSONObjectsResponseSerializer<T: HandyJSON>: ResponseSerializer {
    public typealias SerializedObject = [T?]
    private let designatedPath: String?
    
    /// Init HandyJSONObjectsResponseSerializer
    ///
    /// - Parameter designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    public init(designatedPath: String? = nil) {
        self.designatedPath = designatedPath
    }
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<[SerializedObject?]>`
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `SYMoyaNetworkDataResponse<[SerializedObject?]>`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerHandyJSONObjectsDataResponse(designatedPath: self.designatedPath)
    }
    
    /// Default serializer object
    public static var defaultHandyJSONObjectsSerializer: HandyJSONObjectsResponseSerializer<T> {
        HandyJSONObjectsResponseSerializer<T>()
    }
}

public extension ResponseSerializer {
    /// Create a HandyJSONObjectsResponseSerializer
    ///
    /// - Parameter designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `HandyJSONObjectResponseSerializer<T>`.
    static func handyJSONObjects<T: HandyJSON>(designatedPath: String? = nil) -> HandyJSONObjectsResponseSerializer<T> {
        return HandyJSONObjectsResponseSerializer<T>(designatedPath: designatedPath)
    }
}

