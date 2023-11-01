//
//  SYMoyaProvider+Image.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - SYMoyaProviderImageType
extension SYMoyaProvider {
    public func responseImageFromCache(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<Image>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let image = serializer.serialize(result: result)
            completion(image)
        }
    }
    
    public func responseImageFromDiskCache(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<Image>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let image = serializer.serialize(result: result)
            completion(image)
        }
    }
    
    public func responseImageFromMemoryCache(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer) -> SYMoyaNetworkDataResponse<Image> {
        let result = self.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return response
    }
    
    @discardableResult
    public func responseImage(_ type: ResponseDataSourceType = .server, target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<Image>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let image = serializer.serialize(result: result)
            completion(image)
        }
        return cancellable
    }
}
