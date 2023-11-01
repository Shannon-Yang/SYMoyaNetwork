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

public extension Reactive where Base: SYMoyaProviderRequestable {
    func responseJSONFromCache(_ target: Base.Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.requestFromCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.send(value: response)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
   
    func responseJSONFromDiskCache(_ target: Base.Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.requestFromDiskCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.send(value: response)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
   
    func responseJSONFromMemoryCache(_ target: Base.Target, serializer: JSONResponseSerializer = .defaultJSONSerializer) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        let result = base.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> { observer, lifetime in
            observer.send(value: response)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
   
    func responseJSON(_ type: ResponseDataSourceType = .server, target: Base.Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<Any>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.request(type, target: target, callbackQueue: callbackQueue, progress: progress, completion: { result in
                let response = serializer.serialize(result: result)
                observer.send(value: response)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
