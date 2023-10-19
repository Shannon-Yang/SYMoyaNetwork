//
//  SYMoyaProvider+SwiftyJSON+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/25.
//

import Foundation
import Moya
import SwiftyJSON

//MARK: - SwiftyJSON Provider Concurrency
public extension SYMoyaProvider {

    func responseSwiftyJSONFromCache(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        return await withCheckedContinuation { continuation in
            self.responseSwiftyJSONFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseSwiftyJSONFromDiskCache(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        return await withCheckedContinuation{ continuation in
            self.responseSwiftyJSONFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseSwiftyJSONFromMemoryCache(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer) async ->  SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        return await withCheckedContinuation{ continuation in
            let dataResponse = self.responseSwiftyJSONFromMemoryCache(target, serializer: serializer)
            continuation.resume(returning: dataResponse)
        }
    }
    
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseSwiftyJSON(responseDataSourceType,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                        continuation.resume(returning: dataResponse)
                    }
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
