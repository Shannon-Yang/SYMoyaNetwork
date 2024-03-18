//
//  SYMoyaProvider+String.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - SYMoyaProviderStringType
public extension SYMoyaProvider {
    /// Retrieve data from the cache and parses the retrieved data into an object that is `String`.
    ///
    /// This method will first retrieve data from the memory cache. If the data is retrieved, `completion` will be called back.
    ///
    ///  If there is no data in the memory cache, the disk will continue to be retrieved, and the completion will be called back after the retrieval is completed. refer to ``NetworkCache/retrieveResponse(forKey:options:callbackQueue:completionHandler:)-3l55p``
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - completion: A closure which is invoked when the cache operation finishes. If not specified, the main queue will be used.
    func responseStringFromCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<String>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let string = serializer.serialize(result: result)
            completion(string)
        }
    }
    
    /// Retrieve cached data from disk cache and parses the retrieved data into an object that is `String`.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - completion: A closure which is invoked when the cache operation finishes. If not specified, the main queue will be used.
    func responseStringFromDiskCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<String>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let string = serializer.serialize(result: result)
            completion(string)
        }
    }
    
    /// Retrieve cached data from memory cache and parses the retrieved data into an object that is `String`.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `String`
    func responseStringFromMemoryCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer) -> SYMoyaNetworkDataResponse<String> {
        let result = self.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return response
    }
    
    /// A data request method, depending on the data request strategy. and parses the requested data into an object that is `String`.
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
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseString(_ type: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let string = serializer.serialize(result: result)
            completion(string)
        }
        return cancellable
    }
}
