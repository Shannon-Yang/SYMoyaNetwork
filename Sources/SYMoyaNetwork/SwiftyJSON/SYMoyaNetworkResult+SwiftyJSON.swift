//
//  SYMoyaNetworkResult+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import SwiftyJSON
import Moya

public extension SYMoyaNetworkResult {
    /// Data parsed as `SwiftyJSON.JSON`
    ///
    /// - Parameter opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    /// - Returns: The converted json data
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
