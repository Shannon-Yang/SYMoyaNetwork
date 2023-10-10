//
//  SYMoyaNetworkResult+HandyJSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//

import Foundation
import HandyJSON
import Moya
import SYMoyaNetwork

extension SYMoyaNetworkResult {
    func serializerObjectDataResponse<T: HandyJSON>(designatedPath: String?, isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        let object: T?
        switch self {
        case .success(let response):
            if let designatedPath = designatedPath {
                object = response.mapObject(T.self, designatedPath: designatedPath)
            } else {
                object = response.mapObject(T.self)
            }
            if let obj = object {
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(obj))
            } else {
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: response))))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
    
    func serializerObjectsDataResponse<T: HandyJSON>(designatedPath: String?, isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<[T?]?> {
        var dataRes: SYMoyaNetworkDataResponse<[T?]?>
        let objects: [T?]?
        switch self {
        case .success(let response):
            if let designatedPath = designatedPath {
                objects = response.mapArray(T.self, designatedPath: designatedPath)
            } else {
                objects = response.mapArray(T.self)
            }
            
            if let objs = objects {
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(objs))
            } else {
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: response))))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<[T?]?>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
}
