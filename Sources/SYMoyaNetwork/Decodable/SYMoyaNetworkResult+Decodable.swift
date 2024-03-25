//
//  SYMoyaNetworkResult+Decodable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/9.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    /// Data parsed as `Decodable`
    ///
    /// - Parameters:
    ///   - keyPath: Optional key path at which to parse string.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError`, Success value is `Decodable`
    public func serializerCodableObjectDataResponse<T: Decodable>(atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        switch self {
        case let .success(resultResponse):
            do {
                let codableObject: T = try resultResponse.response.mapCodableObject(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(codableObject))
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
}
