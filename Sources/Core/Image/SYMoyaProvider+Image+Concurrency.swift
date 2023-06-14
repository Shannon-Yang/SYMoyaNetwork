//
//  SYMoyaProvider+Image+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya

//MARK: - String Provider Concurrency
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SYMoyaProvider {

    func responseStringFromCacheContinuation(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation { continuation in
            self.responseStringFromCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseStringFromDiskCacheContinuation(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation{ continuation in
            self.responseStringFromDiskCache(target,atKeyPath: atKeyPath,callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseStringContinuation(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<String> {
        let actor = SYDataResponseActor(provider: self)
        return try await withTaskCancellationHandler {
            try await withCheckedContinuation { continuation in
                 Task {
                     await actor.responseString(responseDataSourceType,target: target,atKeyPath: atKeyPath,callbackQueue: callbackQueue,progress: progress, completion: { dataResponse in
                         continuation.resume(returning: dataResponse)
                     })
                 }
            }
        } onCancel: {
            Task { await actor.cancel() }
        }
    }
}
