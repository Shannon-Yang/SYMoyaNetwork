//
//  BatchDataResponseSerializerProtocol.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import SwiftyJSON
import Moya

//MARK: - String
/// A `ResponseSerializer` that decodes the response data as a `String`.
public protocol ResponseSerializer {
    associatedtype SerializedObject
    
    /// `SYMoyaNetworkResult` serialize to `SYMoyaNetworkDataResponse`, and its value type is `SerializedObject`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError`
    func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject>
}

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

//MARK: - JSON
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
        return result.serializerJSONDataResponse(failsOnEmptyData: failsOnEmptyData)
    }
}

public extension ResponseSerializer where Self == JSONResponseSerializer {
    /// Default serializer object
    static var defaultJSONSerializer: JSONResponseSerializer {
        JSONResponseSerializer()
    }
    
    /// Create a JSONResponseSerializer
    ///
    /// - Parameter failsOnEmptyData: A Boolean value determining
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `JSON`.
    static func json(failsOnEmptyData: Bool) -> JSONResponseSerializer {
        return JSONResponseSerializer(failsOnEmptyData: failsOnEmptyData)
    }
}

//MARK: - SwiftyJSON
/// A `ResponseSerializer` that decodes the response data as a `SwiftyJSON`.
public class SwiftyJSONResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = SwiftyJSON.JSON
    private let opt: JSONSerialization.ReadingOptions
    
    /// Init SwiftyJSONResponseSerializer
    ///
    /// - Parameter opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    public init(ptions opt: JSONSerialization.ReadingOptions = []) {
        self.opt = opt
    }
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `SwiftyJSON.JSON`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerSwiftyJSON(ptions: opt)
    }
}

public extension ResponseSerializer where Self == SwiftyJSONResponseSerializer {
    /// Default serializer object
    static var defaultSwiftyJSONSerializer: SwiftyJSONResponseSerializer {
        SwiftyJSONResponseSerializer()
    }
    
    /// Create a SwiftyJSONResponseSerializer
    ///
    /// - Parameter opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `SwiftyJSON`.
    static func swiftyJSON(ptions opt: JSONSerialization.ReadingOptions = []) -> SwiftyJSONResponseSerializer {
        return SwiftyJSONResponseSerializer(ptions: opt)
    }
}
   
//MARK: - Decodable
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
        return result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
    
    /// Default serializer object
    public static var defaultDecodableSerializer: DecodableResponseSerializer<SerializedObject> {
        DecodableResponseSerializer<SerializedObject>()
    }
}

public extension ResponseSerializer {
    /// Create a DecodableResponseSerializer
    ///
    /// - Parameters:
    ///   - keyPath: Optional key path at which to parse string.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `Decodable`.
    static func decodable<T: Decodable>(atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> DecodableResponseSerializer<T> {
        return DecodableResponseSerializer<T>(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
}

//MARK: - Image
/// A `ResponseSerializer` that decodes the response data as a `Image`.
public class ImageResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = Image
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<Image>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `Image`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerImageDataResponse()
    }
}

public extension ResponseSerializer where Self == ImageResponseSerializer {
    /// Default serializer object
    static var defaultImageSerializer: ImageResponseSerializer {
        ImageResponseSerializer()
    }
    
    /// Create a DecodableResponseSerializer
    ///
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `Image`.
    static func image() -> ImageResponseSerializer {
        return ImageResponseSerializer()
    }
}
