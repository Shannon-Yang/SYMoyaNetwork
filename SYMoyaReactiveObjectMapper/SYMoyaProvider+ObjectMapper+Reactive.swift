//
//  SYMoyaProvider+ObjectMapper+Reactive.swift
//  SYMoyaReactiveObjectMapper
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import SYMoyaNetwork
import ReactiveSwift
import Moya
import ObjectMapper
import SYMoyaObjectMapper


extension Reactive where Base: SYMoyaProviderObjectType {
    
    func responseObjectFromCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            base?.responseObjectFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            base?.responseObjectFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil) -> Observable<SYMoyaNetworkDataResponse<T>> {
        let dataResponse: SYMoyaNetworkDataResponse<T> = base.responseObjectFromMemoryCache(target, keyPath: keyPath, context: context)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseObject(responseDataSourceType, target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }

    func responseObjectsFromCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<[T]>> {
        return Observable.create { [weak base] observer in
            base?.responseObjectsFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<[T]>> {
        return Observable.create { [weak base] observer in
            base?.responseObjectsFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil) -> Observable<SYMoyaNetworkDataResponse<[T]>> {
        let dataResponse: SYMoyaNetworkDataResponse<[T]> = base.responseObjectsFromMemoryCache(target, keyPath: keyPath, context: context)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }

    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Observable<SYMoyaNetworkDataResponse<[T]>> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseObjects(responseDataSourceType, target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
