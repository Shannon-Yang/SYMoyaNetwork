//
//  BatchDataResponseSerializerProtocol.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//

import Foundation
import SwiftyJSON

public protocol BatchDataResponseSerializerProtocol {
    associatedtype SerializedObject
    func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject>
}

public class StringBatchDataResponseSerializer: BatchDataResponseSerializerProtocol {
    public typealias SerializedObject = String
    
    private let atKeyPath: String?
    init(atKeyPath: String? = nil) {
        self.atKeyPath = atKeyPath
    }
    
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerStringDataResponse(atKeyPath: atKeyPath, isDataFromCache: false)
    }
}

public extension BatchDataResponseSerializerProtocol where Self == StringBatchDataResponseSerializer {
    static func string(atKeyPath: String?) -> StringBatchDataResponseSerializer {
        return StringBatchDataResponseSerializer(atKeyPath: atKeyPath)
    }
}

public class JSONBatchDataResponseSerializer: BatchDataResponseSerializerProtocol {
    public typealias SerializedObject = Any
    
    private let failsOnEmptyData: Bool
    init(failsOnEmptyData: Bool = true) {
        self.failsOnEmptyData = failsOnEmptyData
    }
    
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerJSONDataResponse(failsOnEmptyData: failsOnEmptyData, isDataFromCache: false)
    }
}

public extension BatchDataResponseSerializerProtocol where Self == JSONBatchDataResponseSerializer {
    static func json(failsOnEmptyData: Bool) -> JSONBatchDataResponseSerializer {
        return JSONBatchDataResponseSerializer(failsOnEmptyData: failsOnEmptyData)
    }
}


public class SwiftyJSONBatchDataResponseSerializer: BatchDataResponseSerializerProtocol {
    public typealias SerializedObject = SwiftyJSON.JSON
    
    private let opt: JSONSerialization.ReadingOptions
    init(ptions opt: JSONSerialization.ReadingOptions = []) {
        self.opt = opt
    }
    
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerSwiftyJSON(ptions: opt, isDataFromCache: false)
    }
}

public extension BatchDataResponseSerializerProtocol where Self == SwiftyJSONBatchDataResponseSerializer {
    static func swiftyJSON(ptions opt: JSONSerialization.ReadingOptions = []) -> SwiftyJSONBatchDataResponseSerializer {
        return SwiftyJSONBatchDataResponseSerializer(ptions: opt)
    }
}
   


public class CodableBatchDataResponseSerializer<T: Decodable>: BatchDataResponseSerializerProtocol {
    public typealias SerializedObject = T
    
    private let keyPath: String?
    private let decoder: JSONDecoder
    private let failsOnEmptyData: Bool
    
    init(atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool) {
        self.keyPath = keyPath
        self.decoder = decoder
        self.failsOnEmptyData = failsOnEmptyData
    }
    
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, isDataFromCache: false)
    }
}

public extension BatchDataResponseSerializerProtocol where SerializedObject: Decodable {
    static func codable(atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> CodableBatchDataResponseSerializer<SerializedObject> {
        return CodableBatchDataResponseSerializer(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
}
