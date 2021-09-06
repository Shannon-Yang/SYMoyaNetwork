//
//  ResponseDataSourceType.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/30.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Request's responseData source type, implementing different type responseData source type

public enum ResponseDataSourceType {
    
    /// - server: Normal request, the request does not need to cache data, default is normal type
    case server
    
    // 直接从缓存拿，没有缓存直接报错
    case cache
    
    /// - cacheIfPossible: If the request does not cache direct request data,If the current request's cache exist,  will not send network requests, Will return directly to the cache data, This method will only cacheTimeInSeconds set to greater than 0 to store
    
    case cacheIfPossible
    
    /// - cacheAndServer: If the current cache request exist, Will return the cached data, Will return cache Data at first, then send request, Overwrite an existing cache, This method will only cacheTimeInSeconds set to greater than 0 to store
    
    case cacheAndServer
    
    /// - custom: Custom Cache, By implementing CacheCustomizable Protocol, through the service layer to tell whether the current cache to be updated
    
    case custom(ResponseDataSourceCustomizable)
}


/// CacheCustomizable protocol

public protocol ResponseDataSourceCustomizable {
    
    func shouldRequestIfCacheNotExist() -> Bool
    
    /// Custom Request cache operations From Business Logic Layer, indicating the need to send a request
    ///
    /// - Parameter request: current request
    /// - Parameter CacheResponse: cache Response
    /// - Returns: true is send request , false It does not send the request
    
    func shouldSendRequest(_ target: SYTargetType, cacheResponse: Moya.Response) -> Bool
    
    
    /// Custom response cache, By Business Logic Layer to indicate the current cache needs to be updated
    ///
    /// - Parameter request: current request
    /// - Parameter response: current request response
    /// - Returns: if return true, will to update cache,otherwise not update
    
    func shouldUpdateCache(_ target: SYTargetType, response: Moya.Response) -> Bool
}


extension ResponseDataSourceCustomizable {
    
    func shouldRequestIfCacheNotExist() -> Bool {
        return true
    }
    
}
