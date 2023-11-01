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
public extension SYMoyaProvider {
    func responseObjectFromCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation { continuation in
            self.responseObjectFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            self.responseObjectFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, serializer: serializer)
            continuation.resume(returning: dataResponse)
        }
    }
    
    func responseObject<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target,  serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<T> {
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
    
    func responseObjectsFromCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T]> {
        return await withCheckedContinuation { continuation in
            self.responseObjectsFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<[T]> {
        return await withCheckedContinuation { continuation in
            self.responseObjectsFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseObjects<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<[T]> {
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

