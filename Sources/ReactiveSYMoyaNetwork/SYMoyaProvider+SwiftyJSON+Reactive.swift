//
//  SYMoyaProvider+SwiftyJSON+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//

import Foundation
import ReactiveSwift
import Moya
import SYMoyaNetwork
import SwiftyJSON

extension Reactive where Base: SYMoyaProviderSwiftyJSONType {
    func responseSwiftyJSONFromCache(_ target: Base.Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseSwiftyJSONFromCache(target, options: opt, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseSwiftyJSONFromDiskCache(_ target: Base.Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.responseSwiftyJSONFromDiskCache(target, options: opt, callbackQueue: callbackQueue, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    func responseSwiftyJSONFromMemoryCache(_ target: Base.Target, options opt: JSONSerialization.ReadingOptions, failsOnEmptyData: Bool) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
        let dataResponse = base.responseSwiftyJSONFromMemoryCache(target, options: opt, failsOnEmptyData: failsOnEmptyData)
        return SignalProducer<SYMoyaNetworkDataResponse<JSON>, Never> { observer, lifetime in
            observer.send(value: dataResponse)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType, target: Base.Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            let cancellable = base?.responseSwiftyJSON(responseDataSourceType, target: target, options: opt, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                observer.send(value: dataResponse)
                observer.sendCompleted()
            })
            lifetime.observeEnded { cancellable?.cancel() }
        }
    }
}
