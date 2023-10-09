//
//  SYMoyaNetworkResult+Image.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//

import Foundation
import Moya

extension SYMoyaNetworkResult {
    func serializerImageDataResponse(isDataFromCache: Bool) -> SYMoyaNetworkDataResponse<Image> {
        var dataRes: SYMoyaNetworkDataResponse<Image>
        switch self {
        case .success(let response):
            do {
                let image = try response.mapImage()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(image))
            } catch let error {
                let e = (error as! MoyaError).transformToSYMoyaNetworkError()
                dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
            }
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<Image>(response: nil, result: .failure(error))
        }
        dataRes.isDataFromCache = isDataFromCache
        return dataRes
    }
}
