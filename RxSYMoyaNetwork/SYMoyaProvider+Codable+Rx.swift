//
//  SYMoyaProvider+Codable+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/4.
//

import Foundation
import RxSwift
import Moya
import SYMoyaNetwork

extension Reactive where Base: SYMoyaProviderCodableType {
    func responseCodableObjectFromCache<T: Decodable>(_ target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { [weak base] observer in
            base?.responseCodableObjectFromCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseCodableObjectFromDiskCache<T: Decodable>(_ target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<T>>{
        return Observable.create { [weak base] observer in
            base?.responseCodableObjectFromDiskCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseCodableObjectFromMemoryCache<T: Decodable>(_ target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool)  -> Observable<SYMoyaNetworkDataResponse<T>>{
        let dataResponse: SYMoyaNetworkDataResponse<T> = base.responseCodableObjectFromMemoryCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    
    func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<SYMoyaNetworkDataResponse<T>>{
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseCodableObject(responseDataSourceType, target: target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
