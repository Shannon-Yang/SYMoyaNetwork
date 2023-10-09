//
//  SYMoyaNetworkResult+String.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/9.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    func serializerStringDataResponse(atKeyPath: String?, isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<String> {
        var dataRes: SYMoyaNetworkDataResponse<String>
        switch self {
        case .success(let response):
            do {
                let string = try response.mapString(atKeyPath: atKeyPath)
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(string))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<String>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
}

