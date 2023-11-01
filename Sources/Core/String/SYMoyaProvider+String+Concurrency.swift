//
//  SYMoyaProvider+String+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya

//MARK: - String Provider Concurrency
public extension SYMoyaProvider {
    func responseStringFromCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation { continuation in
            self.responseStringFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    func responseStringFromDiskCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation{ continuation in
            self.responseStringFromDiskCache(target,serializer: serializer,callbackQueue: callbackQueue) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    func responseString(_ type: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<String> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseString(type,target: target,serializer: serializer,callbackQueue: callbackQueue,progress: progress, completion: { response in
                        continuation.resume(returning: response)
                    })
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
