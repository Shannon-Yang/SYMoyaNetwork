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
        SignalProducer { [weak base] observer, lifetime in
            base?.responseJSONFromCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
   
    func responseJSONFromDiskCache(_ target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseJSONFromDiskCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
   
    func responseJSONFromMemoryCache(_ target: Base.Target, failsOnEmptyData: Bool) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        let dataResponse = base.responseJSONFromMemoryCache(target, failsOnEmptyData: failsOnEmptyData)
        return SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
   
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseJSON(responseDataSourceType, target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
