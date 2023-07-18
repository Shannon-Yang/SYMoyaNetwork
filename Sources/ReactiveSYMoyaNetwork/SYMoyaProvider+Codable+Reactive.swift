//
//  SYMoyaProvider+Codable+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import ReactiveSwift
import Moya
import SYMoyaNetwork

extension Reactive where Base: SYMoyaProviderCodableType {
    func responseCodableObjectFromCache<T: Decodable>(_ target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseCodableObjectFromCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseCodableObjectFromDiskCache<T: Decodable>(_ target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseCodableObjectFromDiskCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseCodableObjectFromMemoryCache<T: Decodable>(_ target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool)  -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        let dataResponse: SYMoyaNetworkDataResponse<T> = base.responseCodableObjectFromMemoryCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
        return SignalProducer<SYMoyaNetworkDataResponse<T>, Never> { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    
    func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<T>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseCodableObject(responseDataSourceType, target: target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
