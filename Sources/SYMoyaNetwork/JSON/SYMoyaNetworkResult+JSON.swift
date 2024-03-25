//
//  SYMoyaNetworkResult+JSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    /// Data parsed as `JSON`
    ///
    /// - Parameter failsOnEmptyData: A Boolean value determining
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    public func serializerJSONDataResponse(failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<Any> {
        var dataRes: SYMoyaNetworkDataResponse<Any>
        switch self {
        case let .success(resultResponse):
            do {
                let json = try resultResponse.response.mapJSON(failsOnEmptyData: failsOnEmptyData)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(json))
            } catch {
                guard let moyaError = error as? MoyaError else {
                    fatalError("Type as error, Must be of type MoyaError")
                }
                let e = moyaError.transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<Any>(result: .failure(error))
        }
        return dataRes
    }
}
