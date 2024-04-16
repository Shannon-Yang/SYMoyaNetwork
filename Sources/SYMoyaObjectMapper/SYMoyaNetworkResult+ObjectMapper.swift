//
//  SYMoyaNetworkResult+ObjectMapper.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
#if !COCOAPODS
import SYMoyaNetwork
#endif

extension SYMoyaNetworkResult {
    /// Data parsed as `BaseMappable`
    ///
    /// - Parameters:
    ///   - keyPath: A specific map path
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value imp `BaseMappable`
    public func serializerMapperObjectDataResponse<T: BaseMappable>(keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        switch self {
        case let .success(resultResponse):
            do {
                let object: T
                if let keyPath {
                    object = try resultResponse.response.mapObject(T.self, atKeyPath: keyPath, context: context)
                } else {
                    object = try resultResponse.response.mapObject(T.self, context: context)
                }
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(object))
            } catch {
                guard let moyaError = error as? MoyaError else {
                    fatalError("Type as error, Must be of type MoyaError")
                }
                let e = moyaError.transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<T>(result: .failure(error))
        }
        return dataRes
    }

    /// Data parsed as `BaseMappable` array
    ///
    /// - Parameters:
    ///   - keyPath: A specific map path
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value imp `BaseMappable` array
    public func serializerMapperObjectsDataResponse<T: BaseMappable>(keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<[T]> {
        var dataRes: SYMoyaNetworkDataResponse<[T]>
        switch self {
        case let .success(resultResponse):
            do {
                let objects: [T]
                if let keyPath {
                    objects = try resultResponse.response.mapArray(T.self, atKeyPath: keyPath, context: context)
                } else {
                    objects = try resultResponse.response.mapArray(T.self, context: context)
                }
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(objects))
            } catch {
                guard let moyaError = error as? MoyaError else {
                    fatalError("Type as error, Must be of type MoyaError")
                }
                let e = moyaError.transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<[T]>(result: .failure(error))
        }
        return dataRes
    }
}
