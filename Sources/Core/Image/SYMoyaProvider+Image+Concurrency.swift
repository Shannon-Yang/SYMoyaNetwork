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

    func responseImageFromCache(_ target: Target, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Image> {
        return await withCheckedContinuation { continuation in
            self.responseImageFromCache(target, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseImageFromDiskCache(_ target: Target, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Image> {
        return await withCheckedContinuation{ continuation in
            self.responseImageFromDiskCache(target, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseImage(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<Image> {
        let actor = SYDataResponseActor(provider: self)
        return try await withTaskCancellationHandler {
            try await withCheckedContinuation { continuation in
                Task {
                     await actor.responseImage(responseDataSourceType,target: target, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                         continuation.resume(returning: dataResponse)
                     })
                 }
            }
        } onCancel: {
            Task { await actor.cancel() }
        }
    }
}