//
//  SYMoyaProvider+JSON+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - JSON Provider Concurrency
public extension SYMoyaProvider {
    /// Retrieve data from the cache and It will return an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    func responseJSONFromCache(_ target: Target,serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        return await withCheckedContinuation { continuation in
            self.responseJSONFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    /// Retrieve cached data from disk cache and It will return an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    func responseJSONFromDiskCache(_ target: Target,serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        return await withCheckedContinuation{ continuation in
            self.responseJSONFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                continuation.resume(returning: dataResponse)
            }
        }
    }
    
    /// A data request method It will return an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    ///
    /// depending on the data request strategy. and parses the requested data into an object that is `JSON`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: Closure to be executed when progress changes.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `JSON`
    func responseJSON(_ type: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) async -> SYMoyaNetworkDataResponse<Any> {
        let actor = SYDataResponseActor(provider: self)
        return await withTaskCancellationHandler {
             await withCheckedContinuation { continuation in
                _Concurrency.Task {
                     await actor.responseJSON(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                         continuation.resume(returning: dataResponse)
                     })
                 }
            }
        } onCancel: {
            _Concurrency.Task { await actor.cancel() }
        }
    }
}
