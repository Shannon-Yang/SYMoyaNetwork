//
//  SYMoyaProvider+String+Concurrency.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - String Provider Concurrency
public extension SYMoyaProvider {
    /// Retrieve data from the cache and It will return an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
    func responseStringFromCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation { continuation in
            self.responseStringFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    /// Retrieve cached data from disk cache and It will return an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
    func responseStringFromDiskCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<String> {
        return await withCheckedContinuation{ continuation in
            self.responseStringFromDiskCache(target,serializer: serializer,callbackQueue: callbackQueue) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    /// A data request method It will return an object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `Decodable`
    ///
    /// depending on the data request strategy. and parses the requested data into an object that is `String`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: Closure to be executed when progress changes.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
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
