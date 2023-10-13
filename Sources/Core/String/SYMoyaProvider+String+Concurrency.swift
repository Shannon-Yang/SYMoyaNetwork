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
            self.responseStringFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseStringFromDiskCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation{ continuation in
            self.responseStringFromDiskCache(target,serializer: serializer,callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseStringFromMemoryCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation{ continuation in
            let dataResponse = self.responseStringFromMemoryCache(target, serializer: serializer)
            continuation.resume(returning: dataResponse)
        }
    }
    
    func responseString(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<String> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                     await actor.responseString(responseDataSourceType,target: target,serializer: serializer,callbackQueue: callbackQueue,progress: progress, completion: { dataResponse in
                         continuation.resume(returning: dataResponse)
                     })
                 }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
