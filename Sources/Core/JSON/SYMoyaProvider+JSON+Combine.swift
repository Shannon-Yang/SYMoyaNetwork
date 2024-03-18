//
//  SYMoyaProvider+JSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import SwiftyJSON
import Combine

//MARK: - JSON Provider Combine
public extension SYMoyaProvider {
    /// Retrieve data from the cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<JSON>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<JSON>`.
    func responseJSONFromCachePublisher(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            self.responseJSONFromCache(target, serializer: serializer, callbackQueue: callbackQueue, completion: { response in
                _ = subscriber.receive(response)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    /// Retrieve cached data from disk cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<JSON>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<JSON>`.
    func responseJSONFromDiskCachePublisher(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            self.responseJSONFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    /// Retrieve cached data from memory cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<JSON>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `JSON`.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<JSON>`.
    func responseJSONFromMemoryCachePublisher(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse = self.responseJSONFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    /// A data request method,It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<JSON>.
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
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<JSON>`.
    func responseJSONPublisher(_ type: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            return self.responseJSON(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
        }
    }
}
