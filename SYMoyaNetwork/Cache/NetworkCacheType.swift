//
//  NetworkCacheType.swift
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
/// - urlRequestCache: The response is cached in memory.
/// - syMoyaNetworkCache: The response is cached in disk.

public enum NetworkCacheType {

    /// The Request is not cached yet when retrieving it.
    case none
    /// The Request is cached use Http.
    case urlRequestCache(cachePolicy: URLRequestCacheCachePolicy)
    /// The Request is cached in disk or memory
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
        
        public var cacheKey: String = defaultCacheKey
        public var cacheTime: TimeInterval?
        /// The file size limit on disk of the storage in bytes. 0 means no limit.
        public var sizeLimit: UInt
        
        /// The item count limit of the memory storage.
        public var countLimit: Int = .max
        
        /// The time interval between the storage do clean work for swiping expired items.
        public let cleanInterval: TimeInterval
        
        public let diskStorage: DiskStorage.Config
        
        public let memoryStorage: MemoryStorage.Config
        
        public let shouldToCacheDisk: Bool
        
//        init(cacheTime: TimeInterval?, cacheKey: String) {
//            self.cacheTime = cacheTime
//            self.cacheKey = cacheKey
//        }
    }
}


public extension NetworkCacheType {
    
    
}



