//
//  SYMoyaNetworkResult+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//

import Foundation
import SwiftyJSON
import Moya

public extension SYMoyaNetworkResult {
    func serializerSwiftyJSON(ptions opt: JSONSerialization.ReadingOptions = []) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        var dataRes: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>
        switch self {
        case .success(let resultResponse):
            do {
                let json = try resultResponse.response.mapSwiftyJSON(options: opt)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(json))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(result: .failure(error))
        }
        return dataRes
    }
}
