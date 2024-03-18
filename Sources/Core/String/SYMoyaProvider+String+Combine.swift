//
//  SYMoyaProvider+String+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import Combine

//MARK: - SwiftyJSON Provider Combine
public extension SYMoyaProvider {
    /// Retrieve data from the cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<String>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<String>`.
    func responseStringFromCachePublisher(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            self.responseStringFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { response in
                _ = subscriber.receive(response)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    /// Retrieve cached data from disk cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<String>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<String>`.
    func responseStringFromDiskCachePublisher(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            self.responseStringFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { response in
                _ = subscriber.receive(response)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    /// Retrieve cached data from memory cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<String>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<String>`.
    func responseStringFromMemoryCachePublisher(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            let response = self.responseStringFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(response)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    /// A data request method,It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<String>.
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
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<String>`.
    func responseStringPublisher(_ type: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseString(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { response in
                _ = subscriber.receive(response)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
