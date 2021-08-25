//
//  Cache.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/18.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya


public typealias caca = URLRequest.CachePolicy



public enum CachePolicy : UInt {

    /*
     
     服务器返回的响应头中会有这样的字段：Cache-Control: max-age or Cache-Control: s- maxage，通过Cache-Control来指定缓存策略，max-age来表示过期时间。根据这些字段缓存机制再采用如下策略：

     如果本地没有缓存数据，则进行网络请求。
     如果本地有缓存，并且缓存没有失效，则使用缓存。
     如果缓存已经失效，则询问服务器数据是否改变，如果没改变，依然使用缓存，如果改变了则请求新数据。
     如果没有指定是否失效，那么系统将自己判断缓存是否失效。（通常认为是6-24小时的有效时间）
     
     */
    
    case useProtocolCachePolicy = 0 // 默认值，根据http协议进行缓存

    
    case reloadIgnoringLocalCacheData = 1 // 不使用缓存数据，忽略缓存

    case reloadIgnoringLocalAndRemoteCacheData = 4 // Unimplemented

//    public static var reloadIgnoringCacheData: NSURLRequest.CachePolicy { get }

    
    case returnCacheDataElseLoad = 2 // 无论缓存是否过期都是用缓存，没有缓存就进行网络请求

    case returnCacheDataDontLoad = 3  // 无论缓存是否过期都是用缓存，没有缓存也不会进行网络请求

    
    case reloadRevalidatingCacheData = 5 // Unimplemented
}


///  Network Cache type of a cached Request.
/// - none: The Request is not cached yet when retrieving it.
/// - urlRequestCache: The image is cached in memory.
/// - syMoyaNetworkCache: The image is cached in disk.

public enum NetworkCacheType {
    
    /// The Request is not cached yet when retrieving it.
    case none
    /// The Request is cached in memory.
    case urlRequestCache
    /// The Request is cached in disk.
    case syMoyaNetworkCache(responseDataSourceType: ResponseDataSourceType)

    /// Whether the cache type represents the Request is already cached or not.
    public var isUseCache: Bool {
        switch self {
        case .urlRequestCache, .syMoyaNetworkCache: return true
        case .none: return false
        }
    }
}

extension NetworkCacheType {
    
    /// Request's responseData source type, implementing different type responseData source type

    public enum ResponseDataSourceType {
        
        /// - server: Normal request, the request does not need to cache data, default is normal type
        
        case server
        
        /// - cacheIfPossible: If the request does not cache direct request data,If the current request's cache exist, We will not send network requests, Will return directly to the cache data, This method will only cacheTimeInSeconds set to greater than 0 to store
        
        case cacheIfPossible
        
        /// - cacheAndServer: If the current cache request exist, Will return the cached data, Will return cache Data at first, then send request, Overwrite an existing cache, This method will only cacheTimeInSeconds set to greater than 0 to store
        
        case cacheAndServer
        
        /// - custom: Custom Cache, By implementing CacheCustomizable Protocol, through the service layer to tell whether the current cache to be updated
        
        case custom
    }
}

/// CacheCustomizable protocol

public protocol ResponseDataSourceCustomizable {
    
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
