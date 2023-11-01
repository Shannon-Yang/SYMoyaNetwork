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
public extension SYMoyaProvider {
    
    func responseObjectFromCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation { continuation in
            self.responseObjectFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromDiskCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            self.responseObjectFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, serializer: serializer)
            continuation.resume(returning: dataResponse)
        }
    }
    
    func responseObject<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<T> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                        continuation.resume(returning: dataResponse)
                    })
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
    
    func responseObjectsFromCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T?]> {
        return await withCheckedContinuation { continuation in
            self.responseObjectsFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T?]> {
        return await withCheckedContinuation{ continuation in
            self.responseObjectsFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjects<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<[T?]> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseObjects(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                        continuation.resume(returning: dataResponse)
                    })
                }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
