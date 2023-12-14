//
//  SYMoyaProvider+JSON.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - SYMoyaProviderJSONType
extension SYMoyaProvider {
    public func responseJSONFromCache(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<Any>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let json = serializer.serialize(result: result)
            completion(json)
        }
    }
    
    public func responseJSONFromDiskCache(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<Any>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let json = serializer.serialize(result: result)
            completion(json)
        }
    }
    
    public func responseJSONFromMemoryCache(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer) -> SYMoyaNetworkDataResponse<Any> {
        let result = self.requestFromMemoryCache(target)
        let json = serializer.serialize(result: result)
        return json
    }
    
    @discardableResult
    public func responseJSON(_ type: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<Any>) -> Void) -> Moya.Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let json = serializer.serialize(result: result)
            completion(json)
        }
        return cancellable
    }
}
