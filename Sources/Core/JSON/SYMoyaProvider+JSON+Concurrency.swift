//
//  SYMoyaProvider+JSON+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya

//MARK: - String Provider Concurrency
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SYMoyaProvider {

    func responseJSONFromCache(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        return await withCheckedContinuation { continuation in
            self.responseJSONFromCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }

    func responseJSONFromDiskCache(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        return await withCheckedContinuation{ continuation in
            self.responseJSONFromDiskCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }

    func responseJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        let actor = SYDataResponseActor(provider: self)
        return try await withTaskCancellationHandler {
            try await withCheckedContinuation { continuation in
                 Task {
                     await actor.responseJSON(responseDataSourceType,target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                         continuation.resume(returning: dataResponse)
                     })
                 }
            }
        } onCancel: {
            Task { await actor.cancel() }
        }
    }
}
