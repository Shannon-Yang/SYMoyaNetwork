//
//  Result+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//

import Foundation
import SwiftyJSON
import Moya

extension SYMoyaNetworkResult {
    func serializerSwiftyJSON(ptions opt: JSONSerialization.ReadingOptions = [], isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        let dataRes: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>
        switch self {
        case .success(let response):
            do {
                let json = try response.mapSwiftyJSON(options: opt)
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(json))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(response: nil, isDataFromCache: true, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
}
