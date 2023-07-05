//
//  SYMoyaProvider+Image+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import ReactiveSwift
import Moya
import SYMoyaNetwork

extension Reactive where Base: SYMoyaProviderImageType {
    func responseImageFromCache(_ target: Base.Target, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> {
        return Observable.create { [weak base] observer in
            base?.responseImageFromCache(target, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
   
    func responseImageFromDiskCache(_ target: Base.Target, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> {
        return Observable.create { [weak base] observer in
            base?.responseImageFromDiskCache(target, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseImageFromMemoryCache(_ target: Base.Target) -> SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> {
        let dataResponse = base.responseImageFromMemoryCache(target)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    func responseImage(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseImage(responseDataSourceType, target: target, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
