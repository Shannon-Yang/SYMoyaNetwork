//
//  SYMoyaProvider+Codable+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya

//MARK: - SwiftyJSON Provider Concurrency
public extension SYMoyaProvider {

    func responseDecodableFromCache<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation { continuation in
            self.responseDecodableObjectFromCache(target,serializer: serializer,callbackQueue: callbackQueue) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    func responseDecodableFromDiskCache<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
        return await withCheckedContinuation{ continuation in
            self.responseDecodableObjectFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    func responseDecodable<T: Decodable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<T> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                _Concurrency.Task {
                    await actor.responseDecodableObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                         continuation.resume(returning: dataResponse)
                     })
                 }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
