//
//  SYMoyaNetworkResult+String.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/9.
//

import Foundation
import Moya

public extension SYMoyaNetworkResult {
    /// Data parsed as `String`
    ///
    /// - Parameter atKeyPath: Optional key path at which to parse string.
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError`, Success value is `String`
    func serializerStringDataResponse(atKeyPath: String?) -> SYMoyaNetworkDataResponse<String> {
        var dataRes: SYMoyaNetworkDataResponse<String>
        switch self {
        case .success(let resultResponse):
            do {
                let string = try resultResponse.response.mapString(atKeyPath: atKeyPath)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(string))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<String>(result: .failure(error))
        }
        return dataRes
    }
}

