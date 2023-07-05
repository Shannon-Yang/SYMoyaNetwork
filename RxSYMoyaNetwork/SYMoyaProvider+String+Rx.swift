//
//  SYMoyaProvider+String+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/4.
//

import Foundation
import RxSwift
import Moya
import SYMoyaNetwork

extension Reactive where Base: SYMoyaProviderStringType {
    func responseStringFromCache(_ target: Base.Target, atKeyPath: String?, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<String>> {
        return Observable.create { [weak base] observer in
            base?.responseStringFromCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseStringFromDiskCache(_ target: Base.Target, atKeyPath: String?, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<String>>{
        return Observable.create { [weak base] observer in
            base?.responseStringFromDiskCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseStringFromMemoryCache(_ target: Base.Target, atKeyPath: String?) -> Observable<SYMoyaNetworkDataResponse<String>>{
        let dataResponse = base.responseStringFromMemoryCache(target, atKeyPath: atKeyPath)
        return Observable.create { observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    
    func responseString(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, atKeyPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<SYMoyaNetworkDataResponse<String>>{
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseString(responseDataSourceType, target: target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
