//
//  SYMoyaNetworkResult+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

extension SYMoyaNetworkResult {
    /// Data parsed as `SwiftyJSON.JSON`
    ///
    /// - Parameter opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    /// - Returns: The converted json data
    public func serializerSwiftyJSON(ptions opt: JSONSerialization.ReadingOptions = []) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        var dataRes: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>
        switch self {
        case let .success(resultResponse):
            do {
                let json = try resultResponse.response.mapSwiftyJSON(options: opt)
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(json))
            } catch {
                guard let moyaError = error as? MoyaError else {
                    fatalError("Type as error, Must be of type MoyaError")
                }
                let e = moyaError.transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(result: .failure(error))
        }
        return dataRes
    }
}
