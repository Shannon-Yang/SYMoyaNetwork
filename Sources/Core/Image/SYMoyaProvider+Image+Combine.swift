//
//  SYMoyaProvider+Image+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import Combine

//MARK: - Image Provider Combine
public extension SYMoyaProvider {
    /// Retrieve data from the cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<Image>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `Image`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<Image>`.
    func responseImageFromCachePublisher(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            self.responseImageFromCache(target,serializer: serializer,callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    /// Retrieve cached data from disk cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<Image>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `Image`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<Image>`.
    func responseImageFromDiskCachePublisher(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            self.responseImageFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue,completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    /// Retrieve cached data from memory cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<Image>.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `Image`.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<Image>`.
    func responseImageFromMemoryCachePublisher(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse = self.responseImageFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    /// A data request method,It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<Image>.
    ///
    /// depending on the data request strategy. and parses the requested data into an object that is `Image`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `Image`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: Closure to be executed when progress changes.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<Image>`.
    func responseImagePublisher(_ type: ResponseDataSourceType = .server, target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseImage(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
        }
    }
}

