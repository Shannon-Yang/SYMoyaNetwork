//
//  SYMoyaNetworkResult+JSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//

import Foundation
import Moya

public extension SYMoyaNetworkResult {
    /// Data parsed as `JSON`
    /// 
    /// - Parameter failsOnEmptyData: A Boolean value determining
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    func serializerJSONDataResponse(failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<Any> {
        var dataRes: SYMoyaNetworkDataResponse<Any>
        switch self {
        case .success(let resultResponse):
            do {
                let json = try resultResponse.response.mapJSON(failsOnEmptyData: failsOnEmptyData)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(json))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<Any>(result: .failure(error))
        }
        return dataRes
    }
    
}
