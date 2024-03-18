//
//  SYMoyaProvider+SwiftyJSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/25.
//

import Foundation
import Moya
import SwiftyJSON
import Combine

//MARK: - SwiftyJSON Provider Combine
public extension SYMoyaProvider {
    /// Retrieve data from the cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `SwiftyJSON.JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>`.
    func responseSwiftyJSONFromCachePublisher(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            self.responseSwiftyJSONFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    /// Retrieve cached data from disk cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `SwiftyJSON.JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>`.
    func responseSwiftyJSONFromDiskCachePublisher(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            self.responseSwiftyJSONFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    
    /// Retrieve cached data from memory cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `SwiftyJSON.JSON`.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>`.
    func responseSwiftyJSONFromMemoryCachePublisher(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            let json = self.responseSwiftyJSONFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(json)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    /// A data request method,It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>.
    ///
    /// depending on the data request strategy. and parses the requested data into an object that is `SwiftyJSON.JSON`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `SwiftyJSON.JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: Closure to be executed when progress changes.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>`.
    func responseSwiftyJSONPublisher(_ type: ResponseDataSourceType = .server, target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            return self.responseSwiftyJSON(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
