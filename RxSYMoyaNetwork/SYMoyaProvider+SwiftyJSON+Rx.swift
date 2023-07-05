//
//  SYMoyaProvider+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/29.
//

import Foundation
import RxSwift
import Moya
import SYMoyaNetwork
import SwiftyJSON

extension Reactive where Base: SYMoyaProviderSwiftyJSONType {
    func responseSwiftyJSONFromCache(_ target: Base.Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return Observable.create { [weak base] observer in
            base?.responseSwiftyJSONFromCache(target, options: opt, callbackQueue: callbackQueue) { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }
    
    func responseSwiftyJSONFromDiskCache(_ target: Base.Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?) -> Observable<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return Observable.create { [weak base] observer in
            base?.responseSwiftyJSONFromDiskCache(target, options: opt, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            return Disposables.create()
        }
    }
    
    func responseSwiftyJSONFromMemoryCache(_ target: Base.Target, options opt: JSONSerialization.ReadingOptions, failsOnEmptyData: Bool) -> Observable<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        let dataResponse = base.responseSwiftyJSONFromMemoryCache(target, options: opt, failsOnEmptyData: failsOnEmptyData)
        return Observable.create {observer in
            observer.on(.next(dataResponse))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return Observable.create { [weak base] observer in
            let cancellable = base?.responseSwiftyJSON(responseDataSourceType, target: target, options: opt, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            })
            
            return Disposables.create { cancellable?.cancel() }
        }
    }
}
