//
//  SYMoyaProvider+SwiftyJSON+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import ReactiveSwift
import Moya
import SYMoyaNetwork
import SwiftyJSON

public extension Reactive where Base: SYMoyaProviderRequestable {
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    /// - Returns: <#description#>
    func responseSwiftyJSONFromCache(_ target: Base.Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.requestFromCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.send(value: response)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    /// - Returns: <#description#>
    func responseSwiftyJSONFromDiskCache(_ target: Base.Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
        SignalProducer { [weak base] observer, lifetime in
            base?.requestFromDiskCache(target, callbackQueue: callbackQueue, completion: { result in
                let response = serializer.serialize(result: result)
                observer.send(value: response)
                observer.sendCompleted()
            })
            lifetime.observeEnded { }
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    /// - Returns: <#description#>
    func responseSwiftyJSONFromMemoryCache(_ target: Base.Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
        let result = base.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return SignalProducer<SYMoyaNetworkDataResponse<JSON>, Never> { observer, lifetime in
            observer.send(value: response)
            observer.sendCompleted()
            lifetime.observeEnded { }
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: Closure to be executed when progress changes.
    /// - Returns: <#description#>
    func responseSwiftyJSON(_ type: ResponseDataSourceType = .server, target: Base.Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SignalProducer<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>, Never> {
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
