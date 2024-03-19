//
//  SYMoyaProvider+String+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/4.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import SYMoyaNetwork

public extension Reactive where Base: SYMoyaProviderRequestable {
    /// Retrieve data from the cache and parses the retrieved data into an object that is `String`.
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
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    /// - Returns: A type-erased `ObservableType` that can produce values of type `SYMoyaNetworkDataResponse<String>`
    func responseStringFromCache(_ cacheFromType: NetworkCacheFromType = .memoryOrDisk, target: Base.Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<String>> {
        return Observable.create { [weak base] observer in
            base?.requestFromCache(cacheFromType,target: target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    /// A data request method, depending on the data request strategy. and parses the requested data into an object that implements `String`
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
    /// - Returns: A type-erased `ObservableType` that can produce values of type `SYMoyaNetworkDataResponse<String>`
    func responseString(_ type: ResponseDataSourceType = .server, target: Base.Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Observable<SYMoyaNetworkDataResponse<String>>{
        return Observable.create { [weak base] observer in
            let cancellable = base?.request(type, target: target, callbackQueue: callbackQueue, progress: progress, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
