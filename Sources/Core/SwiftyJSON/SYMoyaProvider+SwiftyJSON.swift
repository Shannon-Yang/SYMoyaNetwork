//
//  SYMoyaProvider+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

//MARK: - SYMoyaProviderSwiftyJSONType
extension SYMoyaProvider {
    public func responseSwiftyJSONFromCache(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let json = serializer.serialize(result: result)
            completion(json)
        }
    }
    
    public func responseSwiftyJSONFromDiskCache(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let json = serializer.serialize(result: result)
            completion(json)
        }
    }
    
    public func responseSwiftyJSONFromMemoryCache(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        let result = self.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return response
    }
    
    @discardableResult
    public func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType, target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable? {
        let cancellable = self.request(responseDataSourceType, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let json = serializer.serialize(result: result)
            completion(json)
        }
        return cancellable
    }
}
