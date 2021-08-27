//
//  Cache.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/18.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public typealias URLRequestCacheCachePolicy = URLRequest.CachePolicy

///  Network Cache type of a cached Request.
/// - none: The Request is not cached yet when retrieving it.
/// - urlRequestCache: The image is cached in memory.
/// - syMoyaNetworkCache: The image is cached in disk.

public enum NetworkCacheType {

    /// The Request is not cached yet when retrieving it.
    case none
    /// The Request is cached in memory.
    case urlRequestCache(cachePolicy: URLRequestCacheCachePolicy)
    /// The Request is cached in disk.
    case syMoyaNetworkCache(networkCacheOptionsInfo: NetworkCacheOptionsInfo)

    /// Whether the cache type represents the Request is already cached or not.
    public var isUseCache: Bool {
        switch self {
        case .urlRequestCache, .syMoyaNetworkCache: return true
        case .none: return false
        }
    }
    
    public var isUrlRequestCacheCase: Bool {
        switch self {
        case .urlRequestCache:
            return true
        default:
            return false
        }
    }
}

extension NetworkCacheType: Equatable {
    public static func == (lhs: NetworkCacheType, rhs: NetworkCacheType) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (let .urlRequestCache(lhsCachePolicy), let .urlRequestCache(rhsCachePolicy)):
            return lhsCachePolicy.rawValue == rhsCachePolicy.rawValue
        case (let .syMoyaNetworkCache(lhsNetworkCacheOptionsInfo), let .syMoyaNetworkCache(rhsNetworkCacheOptionsInfo)):
            return lhsNetworkCacheOptionsInfo.cacheKey == rhsNetworkCacheOptionsInfo.cacheKey && lhsNetworkCacheOptionsInfo.cacheTime == rhsNetworkCacheOptionsInfo.cacheTime
        default:
            return false
        }
    }
}


public extension NetworkCacheType {
    
    static let defaultCacheKey: String = "com.shannonyang.SYMoyaNetwork.NetworkCache.Key"
    
    struct NetworkCacheOptionsInfo {
        
        public let cacheKey: String = defaultCacheKey
        public var cacheTime: TimeInterval?
        /// The file size limit on disk of the storage in bytes. 0 means no limit.
        public var sizeLimit: UInt
        
        /// The item count limit of the memory storage.
        public var countLimit: Int = .max
        
        
        /// The time interval between the storage do clean work for swiping expired items.
        public let cleanInterval: TimeInterval
        
        public let diskStorage: DiskStorage.Config
        
        public let memoryStorage: MemoryStorage.Config
        
        init(cacheTime: TimeInterval?, cacheKey: String) {
            self.cacheTime = cacheTime
            self.cacheKey = cacheKey
        }
    }
}


public extension NetworkCacheType {
    
    /// Request's responseData source type, implementing different type responseData source type

    enum ResponseDataSourceType {
        
        /// - server: Normal request, the request does not need to cache data, default is normal type
        case server
        
        case cache
        
        /// - cacheIfPossible: If the request does not cache direct request data,If the current request's cache exist,  will not send network requests, Will return directly to the cache data, This method will only cacheTimeInSeconds set to greater than 0 to store
        
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


