//
//  SYMoyaNetworkResult+JSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    func serializerJSONDataResponse(failsOnEmptyData: Bool, isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<Any> {
        var dataRes: SYMoyaNetworkDataResponse<Any>
        switch self {
        case .success(let response):
            do {
                let json = try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(json))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<Any>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
    
}
