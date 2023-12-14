//
//  SYMoyaProvider+Codable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - SYMoyaProviderCodableType
public extension SYMoyaProvider {
    func responseDecodableObjectFromCache<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let decodable = serializer.serialize(result: result)
            completion(decodable)
        }
    }
    
    func responseDecodableObjectFromDiskCache<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let decodable = serializer.serialize(result: result)
            completion(decodable)
        }
    }
    
    func responseDecodableObjectFromMemoryCache<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer) -> SYMoyaNetworkDataResponse<T> {
        let result = self.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return response
    }
    
    @discardableResult
    func responseDecodableObject<T: Decodable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) -> Moya.Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let string = serializer.serialize(result: result)
            completion(string)
        }
        return cancellable
    }
}
