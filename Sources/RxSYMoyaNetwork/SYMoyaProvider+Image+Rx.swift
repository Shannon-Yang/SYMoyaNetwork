//
//  SYMoyaProvider+Image+Rx.swift
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
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    /// - Returns: <#description#>
    func responseImageFromCache(_ target: Base.Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<Image>> {
        return Observable.create { [weak base] observer in
            base?.requestFromCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
   
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    /// - Returns: <#description#>
    func responseImageFromDiskCache(_ target: Base.Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<Image>> {
        return Observable.create { [weak base] observer in
            base?.requestFromDiskCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    /// - Returns: <#description#>
    func responseImageFromMemoryCache(_ target: Base.Target, serializer: ImageResponseSerializer = .defaultImageSerializer) -> Observable<SYMoyaNetworkDataResponse<Image>> {
        let result = base.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return Observable.create { observer in
            observer.on(.next(response))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    /// - Returns: <#description#>
    func responseImage(_ type: ResponseDataSourceType = .server, target: Base.Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Observable<SYMoyaNetworkDataResponse<Image>> {
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
