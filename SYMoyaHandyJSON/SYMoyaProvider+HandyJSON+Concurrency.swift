//
//  SYMoyaProvider+HandyJSON+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import HandyJSON
import SYMoyaNetwork

//MARK: - HandyJSON Provider Concurrency
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SYMoyaProvider {
    
    func responseObjectFromCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation { continuation in
            self.responseObjectFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            self.responseObjectFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, designatedPath: designatedPath)
            continuation.resume(returning: dataResponse)
        }
    }
    
    func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<T> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseObject(responseDataSourceType,target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                        continuation.resume(returning: dataResponse)
                    })
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
    
    func responseObjectsFromCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T?]?> {
        return await withCheckedContinuation { continuation in
            self.responseObjectsFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T?]?> {
        return await withCheckedContinuation{ continuation in
            self.responseObjectsFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil) async -> SYMoyaNetworkDataResponse<[T?]?> {
        return await withCheckedContinuation{ continuation in
            let dataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.responseObjectsFromMemoryCache(target, designatedPath: designatedPath)
            continuation.resume(returning: dataResponse)
        }
    }
    
    
    
    func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<[T?]?> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseObjects(responseDataSourceType,target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                        continuation.resume(returning: dataResponse)
                    })
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
