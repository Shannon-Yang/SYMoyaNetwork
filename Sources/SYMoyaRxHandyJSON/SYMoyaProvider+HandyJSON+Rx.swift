//
//  SYMoyaProvider+HandyJSON+Rx.swift
//  SYMoyaRxHandyJSON
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import SYMoyaNetwork
import RxSwift
import Moya
import HandyJSON
import SYMoyaHandyJSON

extension Reactive where Base: SYMoyaProviderRequestable {
    public func responseObjectFromCache<T: HandyJSON>(_ target: Base.Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            base?.requestFromCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    public func responseObjectFromDiskCache<T: HandyJSON>(_ target: Base.Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            base?.requestFromDiskCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    public func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Base.Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer) -> Observable<SYMoyaNetworkDataResponse<T>> {
        let result = base.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return Observable.create { observer in
            observer.on(.next(response))
            observer.on(.completed)
            return Disposables.create()
        }
        
    }
    
    public func responseObject<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Base.Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.request(type, target: target, callbackQueue: callbackQueue, progress: progress, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
    
    public func responseObjectsFromCache<T: HandyJSON>(_ target: Base.Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<[T?]>> {
        return Observable.create { [weak base] observer  in
            base?.requestFromCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    public func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Base.Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<[T?]>> {
        return Observable.create { [weak base] observer  in
            base?.requestFromDiskCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.on(.next(response))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    public func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Base.Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer) -> Observable<SYMoyaNetworkDataResponse<[T?]>> {
        let result = base.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return Observable.create { observer in
            observer.on(.next(response))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    public func responseObjects<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Base.Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Observable<SYMoyaNetworkDataResponse<[T?]>> {
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
