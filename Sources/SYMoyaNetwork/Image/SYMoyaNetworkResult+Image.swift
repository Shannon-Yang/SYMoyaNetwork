//
//  SYMoyaNetworkResult+Image.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    /// Data parsed as `Image`
    ///
    /// - Returns: an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `Image`
    public func serializerImageDataResponse() -> SYMoyaNetworkDataResponse<Image> {
        var dataRes: SYMoyaNetworkDataResponse<Image>
        switch self {
        case let .success(resultResponse):
            do {
                let image = try resultResponse.response.mapImage()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .success(image))
            } catch {
                guard let moyaError = error as? MoyaError else {
                    fatalError("Type as error, Must be of type MoyaError")
                }
                let e = moyaError.transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(resultResponse: resultResponse, result: .failure(e))
            }
        case let .failure(error):
            dataRes = SYMoyaNetworkDataResponse<Image>(result: .failure(error))
        }
        return dataRes
    }
}
