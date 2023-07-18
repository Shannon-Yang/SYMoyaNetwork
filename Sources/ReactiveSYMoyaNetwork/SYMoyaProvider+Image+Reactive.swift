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
        SignalProducer { [weak base] observer, lifetime in
            base?.responseImageFromCache(target, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
   
    func responseImageFromDiskCache(_ target: Base.Target, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseImageFromDiskCache(target, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseImageFromMemoryCache(_ target: Base.Target) -> SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> {
        let dataResponse = base.responseImageFromMemoryCache(target)
        return SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    func responseImage(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<Image>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseImage(responseDataSourceType, target: target, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
