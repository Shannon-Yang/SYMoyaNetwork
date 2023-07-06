//
//  SYMoyaProvider+String+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import ReactiveSwift
import Moya
import SYMoyaNetwork

extension Reactive where Base: SYMoyaProviderStringType {
    func responseStringFromCache(_ target: Base.Target, atKeyPath: String?, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<String>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseStringFromCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseStringFromDiskCache(_ target: Base.Target, atKeyPath: String?, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<String>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseStringFromDiskCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseStringFromMemoryCache(_ target: Base.Target, atKeyPath: String?) -> SignalProducer<SYMoyaNetworkDataResponse<String>, Never> {
        let dataResponse = base.responseStringFromMemoryCache(target, atKeyPath: atKeyPath)
        return SignalProducer<SYMoyaNetworkDataResponse<String>, Never> { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    
    func responseString(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, atKeyPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<String>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseString(responseDataSourceType, target: target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
