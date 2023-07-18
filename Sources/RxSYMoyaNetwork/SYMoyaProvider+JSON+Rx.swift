//
//  SYMoyaProvider+JSON+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/4.
//

import Foundation
import RxSwift
import Moya
import SYMoyaNetwork

extension Reactive where Base: SYMoyaProviderJSONType {
    func responseJSONFromCache(_ target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<Any>> {
        return Observable.create { [weak base] observer in
            base?.responseJSONFromCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
   
    func responseJSONFromDiskCache(_ target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<Any>> {
        return Observable.create { [weak base] observer in
            base?.responseJSONFromDiskCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
   
    func responseJSONFromMemoryCache(_ target: Base.Target, failsOnEmptyData: Bool) -> Observable<SYMoyaNetworkDataResponse<Any>> {
        let dataResponse = base.responseJSONFromMemoryCache(target, failsOnEmptyData: failsOnEmptyData)
        return Observable.create { observer in            
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
   
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<SYMoyaNetworkDataResponse<Any>> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseJSON(responseDataSourceType, target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
