//
//  SYMoyaProvider+HandyJSON+Reactive.swift
//  SYMoyaReactiveHandyJSON
//
//  Created by Shannon Yang on 2023/7/6.
//

import Foundation
import SYMoyaNetwork
import ReactiveSwift
import Moya
import HandyJSON
import SYMoyaHandyJSON

extension Reactive where Base: SYMoyaProviderHandyJSONType {
    public func responseObjectFromCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    
    public func responseObjectFromDiskCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    
    public func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        let dataResponse: SYMoyaNetworkDataResponse<T> = base.responseObjectFromMemoryCache(target, designatedPath: designatedPath)
        return SignalProducer { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    public func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseObject(responseDataSourceType, target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
    
    
    public func responseObjectsFromCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<[T?]?>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectsFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    
    public func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<[T?]?>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseObjectsFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    
    public func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?) -> SignalProducer<SYMoyaNetworkDataResponse<[T?]?>, Never> {
        let dataResponse: SYMoyaNetworkDataResponse<[T?]?> = base.responseObjectsFromMemoryCache(target, designatedPath: designatedPath)
        return SignalProducer { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    
    public func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<[T?]?>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseObjects(responseDataSourceType, target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
