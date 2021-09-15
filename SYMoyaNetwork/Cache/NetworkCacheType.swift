//
//  NetworkCacheType.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/18.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

///  Network Cache type of a cached Request.
/// - none: The Request is not cached yet when retrieving it.
/// - urlRequestCache: The response is cached in memory.
/// - syMoyaNetworkCache: The response is cached in disk.

public enum NetworkCacheType {

    /// The Request is not cached yet when retrieving it.
    case none
    /// The Request is cached use Http.
    case urlRequestCache(urlCacheInfo: URLCacheInfo)
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

public extension NetworkCacheType {
    
    static let defaultCacheKey: String = "com.shannonyang.SYMoyaNetwork.NetworkCache.Key"
    
    struct NetworkCacheOptionsInfo {
        
        public var cacheKey: String = defaultCacheKey
    
        public var diskStorageConfig: DiskStorage.Config
        
        public var memoryStorageConfig: MemoryStorage.Config
        
        init(cacheKey: String = defaultCacheKey, diskStorageConfig: DiskStorage.Config, memoryStorageConfig: MemoryStorage.Config) {
            self.cacheKey = cacheKey
            self.diskStorageConfig = diskStorageConfig
            self.memoryStorageConfig = memoryStorageConfig
        }
    }
}

public extension NetworkCacheType {
    
    struct URLCacheInfo {
        
        public let ignoreServer: Bool
        
        public var HTTPVersion: String {
            didSet {
                if self.HTTPVersion.contains("1.0") {
                    self.isCanUseCacheControl = false
                }
            }
        }
        
        private(set) var isCanUseCacheControl = true
        
        public var maxAge: Int
        
        public var isPrivate: Bool = false
        
        public var autoClearCache: Bool
        
        init(ignoreServer: Bool = true, maxAge: Int, autoClearCache: Bool, isPrivate: Bool = false, HTTPVersion: String = "HTTP/1.1") {
            self.ignoreServer = ignoreServer
            self.maxAge = maxAge
            self.autoClearCache = autoClearCache
            self.isPrivate = isPrivate
            self.HTTPVersion = HTTPVersion
        }
    }
    
}



