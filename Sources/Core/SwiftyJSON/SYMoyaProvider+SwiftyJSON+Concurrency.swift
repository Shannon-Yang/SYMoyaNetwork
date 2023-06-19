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
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SYMoyaProvider {

    func responseSwiftyJSONFromCache(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        return await withCheckedContinuation { continuation in
            self.responseSwiftyJSONFromCache(target, options: opt, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseSwiftyJSONFromDiskCache(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        return await withCheckedContinuation{ continuation in
            self.responseSwiftyJSONFromDiskCache(target, options: opt, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        let actor = SYDataResponseActor(provider: self)
        return try await withTaskCancellationHandler {
            try await withCheckedContinuation { continuation in
                Task {
                    await actor.responseSwiftyJSON(responseDataSourceType,target: target, options: opt, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                        continuation.resume(returning: dataResponse)
                    }
                }
            }
        } onCancel: {
            Swift.Task { await actor.cancel() }
        }
    }
}
