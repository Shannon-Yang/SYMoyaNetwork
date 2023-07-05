//
//  SYMoyaProvider+JSON+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import ReactiveSwift
import Moya
import SYMoyaNetwork

extension Reactive where Base: SYMoyaProviderJSONType {
    func responseJSONFromCache(_ target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        return Observable.create { [weak base] observer in
            base?.responseJSONFromCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
   
    func responseJSONFromDiskCache(_ target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        return Observable.create { [weak base] observer in
            base?.responseJSONFromDiskCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
   
    func responseJSONFromMemoryCache(_ target: Base.Target, failsOnEmptyData: Bool) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        let dataResponse = base.responseJSONFromMemoryCache(target, failsOnEmptyData: failsOnEmptyData)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
   
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseJSON(responseDataSourceType, target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
