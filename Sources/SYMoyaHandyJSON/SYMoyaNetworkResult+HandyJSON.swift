//
//  SYMoyaNetworkResult+HandyJSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import HandyJSON
import Moya
import SYMoyaNetwork

extension SYMoyaNetworkResult {
    /// Data parsed as `HandyJSON`
    ///
    /// - Parameter designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value imp `HandyJSON`
    public func serializerHandyJSONObjectDataResponse<T: HandyJSON>(designatedPath: String?) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        let object: T?
        switch self {
        case let .success(resultResponse):
            if let designatedPath {
                object = resultResponse.response.mapObject(T.self, designatedPath: designatedPath)
            } else {
                object = resultResponse.response.mapObject(T.self)
            }
            if let obj = object {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(obj))
            } else {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: resultResponse.response))))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<T>(result: .failure(error))
        }
        return dataRes
    }

    /// Data parsed as `HandyJSON` array
    ///
    /// - Parameter designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value imp `HandyJSON` array
    public func serializerHandyJSONObjectsDataResponse<T: HandyJSON>(designatedPath: String?) -> SYMoyaNetworkDataResponse<[T?]> {
        var dataRes: SYMoyaNetworkDataResponse<[T?]>
        let objects: [T?]?
        switch self {
        case let .success(resultResponse):
            if let designatedPath {
                objects = resultResponse.response.mapArray(T.self, designatedPath: designatedPath)
            } else {
                objects = resultResponse.response.mapArray(T.self)
            }

            if let objs = objects {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(objs))
            } else {
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: resultResponse.response))))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<[T?]>(result: .failure(error))
        }
        return dataRes
    }
}
