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

extension Reactive where Base: SYMoyaProviderHandyJSONType {
    public func responseObjectFromCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            base?.responseObjectFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    
    public func responseObjectFromDiskCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            base?.responseObjectFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    
    public func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?) -> Observable<SYMoyaNetworkDataResponse<T>> {
        let dataResponse: SYMoyaNetworkDataResponse<T> = base.responseObjectFromMemoryCache(target, designatedPath: designatedPath)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
        
    }
    
    public func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseObject(responseDataSourceType, target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
    
    
    public func responseObjectsFromCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<[T?]?>> {
        return Observable.create { [weak base] observer  in
            base?.responseObjectsFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    
    public func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<[T?]?>> {
        return Observable.create { [weak base] observer  in
            base?.responseObjectsFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    
    public func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Base.Target, designatedPath: String?) -> Observable<SYMoyaNetworkDataResponse<[T?]?>> {
        let dataResponse: SYMoyaNetworkDataResponse<[T?]?> = base.responseObjectsFromMemoryCache(target, designatedPath: designatedPath)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    
    public func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<SYMoyaNetworkDataResponse<[T?]?>> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseObjects(responseDataSourceType, target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
