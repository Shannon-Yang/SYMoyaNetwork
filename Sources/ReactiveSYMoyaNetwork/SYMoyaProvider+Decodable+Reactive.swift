//
//  SYMoyaProvider+Decodable+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import ReactiveSwift
import Moya
import SYMoyaNetwork

public extension Reactive where Base: SYMoyaProviderRequestable {
    func responseDecodableObjectFromCache<T: Decodable>(_ target: Base.Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.requestFromCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.send(value: response)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseDecodableObjectFromDiskCache<T: Decodable>(_ target: Base.Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.requestFromDiskCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.send(value: response)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseDecodableObjectFromMemoryCache<T: Decodable>(_ target: Base.Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer)  -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        let result = base.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return SignalProducer<SYMoyaNetworkDataResponse<T>, Never> { observer, lifetime in
            observer.send(value: response)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    func responseDecodableObject<T: Decodable>(_ type: ResponseDataSourceType = .server, target: Base.Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
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
