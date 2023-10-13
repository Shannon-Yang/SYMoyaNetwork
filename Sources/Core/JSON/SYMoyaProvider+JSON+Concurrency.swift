//
//  SYMoyaProvider+JSON+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya

//MARK: - String Provider Concurrency
public extension SYMoyaProvider {

    func responseJSONFromCache(_ target: Target,serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        return await withCheckedContinuation { continuation in
            self.responseJSONFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }

    func responseJSONFromDiskCache(_ target: Target,serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        return await withCheckedContinuation{ continuation in
            self.responseJSONFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseJSONFromMemoryCache(_ target: Target,serializer: JSONResponseSerializer = .defaultJSONSerializer) async -> SYMoyaNetworkDataResponse<Any> {
        return await withCheckedContinuation{ continuation in
            let dataResponse = self.responseJSONFromMemoryCache(target, serializer: serializer)
            continuation.resume(returning: dataResponse)
        }
    }

    func responseJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
             await withCheckedContinuation { continuation in
                _Concurrency.Task {
                     await actor.responseJSON(responseDataSourceType,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                         continuation.resume(returning: dataResponse)
                     })
                 }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
