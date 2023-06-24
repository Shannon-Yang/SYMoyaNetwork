//
//  SYMoyaProvider+ObjectMapper+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import ObjectMapper
import SYMoyaNetwork

//MARK: - ObjectMapper Provider Concurrency
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SYMoyaProvider {

    func responseObjectFromCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation { continuation in
            self.responseObjectFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            self.responseObjectFromDiskCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, keyPath: keyPath, context: context)
            continuation.resume(returning: dataResponse)
        }
    }
    
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<T> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseObject(responseDataSourceType,target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                        continuation.resume(returning: dataResponse)
                    })
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
    
    func responseObjectsFromCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T]> {
        return await withCheckedContinuation { continuation in
            self.responseObjectsFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T]> {
        return await withCheckedContinuation { continuation in
            self.responseObjectsFromDiskCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) async -> SYMoyaNetworkDataResponse<[T]> {
        return await withCheckedContinuation{ continuation in
            let dataResponse: SYMoyaNetworkDataResponse<[T]> = self.responseObjectsFromMemoryCache(target, keyPath: keyPath, context: context)
            continuation.resume(returning: dataResponse)
        }
    }
    
    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<[T]> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseObjects(responseDataSourceType,target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                        continuation.resume(returning: dataResponse)
                    })
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}

