//
//  SYMoyaNetworkResult.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/11.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Data request response object, `isDataFromCache` indicates whether the currently retrieved data comes from the cache
public typealias SYMoyaNetworkResultResponse = (response: Moya.Response, isDataFromCache: Bool)

/// A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
public typealias SYMoyaNetworkResult = Result<SYMoyaNetworkResultResponse, SYMoyaNetworkError>

extension SYMoyaNetworkResult {
    /// Convert `SYMoyaNetworkDataResponse` to an object of Data type
    /// - Returns:  Represents a response to a `SYMoyaProvider.request`.
    func serializerDataResponse() -> SYMoyaNetworkDataResponse<Data> {
        var dataRes: SYMoyaNetworkDataResponse<Data>
        switch self {
        case let .success(resultResponse):
            dataRes = SYMoyaNetworkDataResponse<Data>(resultResponse: resultResponse, result: .success(resultResponse.response.data))
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<Data>(result: .failure(error))
        }
        return dataRes
    }
}
