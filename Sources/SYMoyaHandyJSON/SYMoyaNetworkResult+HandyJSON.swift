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

public extension SYMoyaNetworkResult {
    func serializerHandyJSONObjectDataResponse<T: HandyJSON>(designatedPath: String?) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        let object: T?
        switch self {
        case .success(let resultResponse):
            if let designatedPath = designatedPath {
                object = resultResponse.response.mapObject(T.self, designatedPath: designatedPath)
            } else {
                object = resultResponse.response.mapObject(T.self)
            }
            if let obj = object {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(obj))
            } else {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: resultResponse.response))))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<T>(result: .failure(error))
        }
        return dataRes
    }
    
    func serializerHandyJSONObjectsDataResponse<T: HandyJSON>(designatedPath: String?) -> SYMoyaNetworkDataResponse<[T?]> {
        var dataRes: SYMoyaNetworkDataResponse<[T?]>
        let objects: [T?]?
        switch self {
        case .success(let resultResponse):
            if let designatedPath = designatedPath {
                objects = resultResponse.response.mapArray(T.self, designatedPath: designatedPath)
            } else {
                objects = resultResponse.response.mapArray(T.self)
            }
            
            if let objs = objects {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(objs))
            } else {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: resultResponse.response))))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<[T?]>(result: .failure(error))
        }
        return dataRes
    }
}
