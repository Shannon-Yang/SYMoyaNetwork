//
//  BatchDataResponseSerializerProtocol.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//

import Foundation
import SwiftyJSON
import Moya

public protocol ResponseSerializer {
    associatedtype SerializedObject
    func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject>
}

public class StringResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = String
    
    private let atKeyPath: String?
    init(atKeyPath: String? = nil) {
        self.atKeyPath = atKeyPath
    }
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerStringDataResponse(atKeyPath: atKeyPath)
    }
}

public extension ResponseSerializer where Self == StringResponseSerializer {
    static var defaultStringSerializer: StringResponseSerializer {
        StringResponseSerializer()
    }
    static func string(atKeyPath: String?) -> StringResponseSerializer {
        return StringResponseSerializer(atKeyPath: atKeyPath)
    }
}

public class JSONResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = Any
    
    private let failsOnEmptyData: Bool
    init(failsOnEmptyData: Bool = true) {
        self.failsOnEmptyData = failsOnEmptyData
    }
    
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerJSONDataResponse(failsOnEmptyData: failsOnEmptyData)
    }
}

public extension ResponseSerializer where Self == JSONResponseSerializer {
    static var defaultJSONSerializer: JSONResponseSerializer {
        JSONResponseSerializer()
    }
    
    static func json(failsOnEmptyData: Bool) -> JSONResponseSerializer {
        return JSONResponseSerializer(failsOnEmptyData: failsOnEmptyData)
    }
}


public class SwiftyJSONResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = SwiftyJSON.JSON
    
    private let opt: JSONSerialization.ReadingOptions
    init(ptions opt: JSONSerialization.ReadingOptions = []) {
        self.opt = opt
    }
    
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerSwiftyJSON(ptions: opt)
    }
}

public extension ResponseSerializer where Self == SwiftyJSONResponseSerializer {
    static var defaultSwiftyJSONSerializer: SwiftyJSONResponseSerializer {
        SwiftyJSONResponseSerializer()
    }
    
    static func swiftyJSON(ptions opt: JSONSerialization.ReadingOptions = []) -> SwiftyJSONResponseSerializer {
        return SwiftyJSONResponseSerializer(ptions: opt)
    }
}
   

public class CodableResponseSerializer<T: Decodable>: ResponseSerializer {
    public typealias SerializedObject = T
    
    private let keyPath: String?
    private let decoder: JSONDecoder
    private let failsOnEmptyData: Bool
    
    init(atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) {
        self.keyPath = keyPath
        self.decoder = decoder
        self.failsOnEmptyData = failsOnEmptyData
    }
    
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
}

public extension ResponseSerializer where Self == CodableResponseSerializer<CodableResponseSerializer.SerializedObject> {
    
    static var defaultCodableSerializer: CodableResponseSerializer<SerializedObject> {
        CodableResponseSerializer<SerializedObject>()
    }
    
    static func codable(atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> CodableResponseSerializer<SerializedObject> {
        return CodableResponseSerializer(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
}


public class ImageResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = Image
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerImageDataResponse()
    }
}


public extension ResponseSerializer where Self == ImageResponseSerializer {
    
    static var defaultImageSerializer: ImageResponseSerializer {
        ImageResponseSerializer()
    }
    
    static func image() -> ImageResponseSerializer {
        return ImageResponseSerializer()
    }
}
