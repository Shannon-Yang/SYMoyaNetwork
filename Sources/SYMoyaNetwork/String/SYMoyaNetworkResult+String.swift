//
//  SYMoyaNetworkResult+String.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/9.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    /// Data parsed as `String`
    ///
    /// - Parameter atKeyPath: Optional key path at which to parse string.
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
    public func serializerStringDataResponse(atKeyPath: String?) -> SYMoyaNetworkDataResponse<String> {
        var dataRes: SYMoyaNetworkDataResponse<String>
        switch self {
        case let .success(resultResponse):
            do {
                let string = try resultResponse.response.mapString(atKeyPath: atKeyPath)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(string))
            } catch {
                guard let moyaError = error as? MoyaError else {
                    fatalError("Type as error, Must be of type MoyaError")
                }
                let e = moyaError.transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<String>(result: .failure(error))
        }
        return dataRes
    }
}
