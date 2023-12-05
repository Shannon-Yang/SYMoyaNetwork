//
//  SYMoyaNetworkResult.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/11.
//

import Foundation
import Moya

public typealias SYMoyaNetworkResultResponse = (response: Moya.Response, isDataFromCache: Bool)
public typealias SYMoyaNetworkResult = Result<SYMoyaNetworkResultResponse, SYMoyaNetworkError>

public extension SYMoyaNetworkResult {
    func serializerDataResponse() -> SYMoyaNetworkDataResponse<Data> {
        var dataRes: SYMoyaNetworkDataResponse<Data>
        switch self {
        case .success(let resultResponse):
            dataRes = SYMoyaNetworkDataResponse<Data>(resultResponse: resultResponse, result: .success(resultResponse.response.data))
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<Data>(result: .failure(error))
        }
        return dataRes
    }
}
