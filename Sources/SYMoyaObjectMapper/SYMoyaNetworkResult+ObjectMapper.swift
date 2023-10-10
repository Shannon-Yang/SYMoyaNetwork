//
//  SYMoyaNetworkResult+ObjectMapper.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//

import Foundation
import Moya
import ObjectMapper
import SYMoyaNetwork

extension SYMoyaNetworkResult {
    func serializerObjectDataResponse<T: BaseMappable>(keyPath: String?, context: MapContext?, isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        switch self {
        case .success(let response):
            do {
                let object: T
                if let keyPath = keyPath {
                    object = try response.mapObject(T.self, atKeyPath: keyPath, context: context)
                } else {
                    object = try response.mapObject(T.self, context: context)
                }
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(object))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
    
    func serializerObjectsDataResponse<T: BaseMappable>(keyPath: String?, context: MapContext?, isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<[T]> {
        var dataRes: SYMoyaNetworkDataResponse<[T]>
        switch self {
        case .success(let response):
            do {
                let objects: [T]
                if let keyPath = keyPath {
                    objects = try response.mapArray(T.self, atKeyPath: keyPath, context: context)
                } else {
                    objects = try response.mapArray(T.self, context: context)
                }
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(objects))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
}
