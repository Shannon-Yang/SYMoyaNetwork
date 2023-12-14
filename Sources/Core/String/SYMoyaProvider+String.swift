//
//  SYMoyaProvider+String.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - SYMoyaProviderStringType
public extension SYMoyaProvider {
    func responseStringFromCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<String>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let string = serializer.serialize(result: result)
            completion(string)
        }
    }
    
    func responseStringFromDiskCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<String>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let string = serializer.serialize(result: result)
            completion(string)
        }
    }
    
    func responseStringFromMemoryCache(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer) -> SYMoyaNetworkDataResponse<String> {
        let result = self.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return response
    }
    
    @discardableResult
    func responseString(_ type: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let string = serializer.serialize(result: result)
            completion(string)
        }
        return cancellable
    }
}
