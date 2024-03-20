//
//  SYMoyaNetworkResult+Image.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public extension SYMoyaNetworkResult {
    /// Data parsed as `Image`
    ///
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `Image`
    func serializerImageDataResponse() -> SYMoyaNetworkDataResponse<Image> {
        var dataRes: SYMoyaNetworkDataResponse<Image>
        switch self {
        case .success(let resultResponse):
            do {
                let image = try resultResponse.response.mapImage()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(image))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<Image>(result: .failure(error))
        }
        return dataRes
    }
}
