//
//  SYMoyaNetworkResult+Codable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/9.
//

import Foundation
import Moya

public extension SYMoyaNetworkResult {
    /// Data parsed as `Decodable`
    ///
    /// - Parameters:
    ///   - keyPath: Optional key path at which to parse string.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError`, Success value is `Decodable`
    func serializerCodableObjectDataResponse<T: Decodable>(atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<T> {
        var dataRes: SYMoyaNetworkDataResponse<T>
        switch self {
        case .success(let resultResponse):
            do {
                let codableObject: T = try resultResponse.response.mapCodableObject(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(codableObject))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<T>(result: .failure(error))
        }
        return dataRes
    }
}
