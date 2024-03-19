//
//  SYMoyaProvider+Image+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import Combine

//MARK: - Image Provider Combine
public extension SYMoyaProvider {
    /// Retrieve data from the cache and It will return an object that implements `Publisher` and outputs the value `SYMoyaNetworkDataResponse<Image>.
    ///
    /// If the type of `cacheFromType` is `.memoryOrDisk`, This method will first retrieve data from the memory cache. If the data is retrieved, `completion` will be called back.
    ///
    ///  If there is no data in the memory cache, the disk will continue to be retrieved, and the `completion` will be called back after the retrieval is completed. refer to ``NetworkCache/retrieveResponse(forKey:options:callbackQueue:completionHandler:)-3l55p``
    ///
    ///  If the type of `cacheFromType` is `.memory`, this method will retrieve data from the memory cache.
    ///
    ///  If the type of `cacheFromType` is `.disk`, this method will retrieve data from the memory cache.
    ///
    ///  When cacheFromType is `.memory` or `.disk`, only one retrieval operation will be performed
    ///  For example: If there is data in the disk cache but not in the memory, and `cacheFromType` is `.memory`, the data will only be retrieved from the memory.
    ///  If there is no data in the memory, you will get `SYMoyaNetworkError.responseNotExisting` and will not continue to retrieve from the disk.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `Image`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: An object that implements `Publisher`, its output value is `SYMoyaNetworkDataResponse<Image>`.
    func responseImageFromCachePublisher(_ cacheFromType: NetworkCacheFromType = .memoryOrDisk, target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            self.responseImageFromCache(cacheFromType,target: target,serializer: serializer,callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
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

