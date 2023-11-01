//
//  SYMoyaProvider+String+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/4.
//

import Foundation
import RxSwift
import Moya
import SYMoyaNetwork

public extension Reactive where Base: SYMoyaProviderRequestable {
    func responseStringFromCache(_ target: Base.Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<String>> {
        return Observable.create { [weak base] observer in
            base?.requestFromCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseStringFromDiskCache(_ target: Base.Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<String>>{
        return Observable.create { [weak base] observer in
            base?.requestFromDiskCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseStringFromMemoryCache(_ target: Base.Target, serializer: StringResponseSerializer = .defaultStringSerializer) -> Observable<SYMoyaNetworkDataResponse<String>>{
        let result = base.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return Observable.create { observer in
            observer.on(.next(response))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    
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
