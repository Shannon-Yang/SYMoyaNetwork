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
    func serializerMapperObjectDataResponse<T: BaseMappable>(keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        switch self {
        case .success(let resultResponse):
            do {
                let object: T
                if let keyPath = keyPath {
                    object = try resultResponse.response.mapObject(T.self, atKeyPath: keyPath, context: context)
                } else {
                    object = try resultResponse.response.mapObject(T.self, context: context)
                }
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(object))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<T>(result: .failure(error))
        }
        return dataRes
    }
    
    func serializerMapperObjectsDataResponse<T: BaseMappable>(keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<[T]> {
        var dataRes: SYMoyaNetworkDataResponse<[T]>
        switch self {
        case .success(let resultResponse):
            do {
                let objects: [T]
                if let keyPath = keyPath {
                    objects = try resultResponse.response.mapArray(T.self, atKeyPath: keyPath, context: context)
                } else {
                    objects = try resultResponse.response.mapArray(T.self, context: context)
                }
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(objects))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<[T]>(result: .failure(error))
        }
        return dataRes
    }
}
