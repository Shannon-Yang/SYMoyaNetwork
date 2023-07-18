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
    
    func responseObjectFromCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        let dataResponse: SYMoyaNetworkDataResponse<T> = base.responseObjectFromMemoryCache(target, keyPath: keyPath, context: context)
        return SignalProducer<SYMoyaNetworkDataResponse<T>, Never> { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseObject(responseDataSourceType, target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }

    func responseObjectsFromCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<[T]>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectsFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }

    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<[T]>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectsFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }

    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Base.Target, keyPath: String? = nil, context: MapContext? = nil) -> SignalProducer<SYMoyaNetworkDataResponse<[T]>, Never> {
        let dataResponse: SYMoyaNetworkDataResponse<[T]> = base.responseObjectsFromMemoryCache(target, keyPath: keyPath, context: context)
        return SignalProducer { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }

    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Base.Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<[T]>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseObjects(responseDataSourceType, target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
