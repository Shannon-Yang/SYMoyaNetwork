//
//  SYMoyaNetworkResult+Codable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/9.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    func serializerCodableObjectDataResponse<T: Decodable>(atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        switch self {
        case .success(let response):
            do {
                let codableObject: T = try response.mapCodableObject(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(codableObject))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
}
