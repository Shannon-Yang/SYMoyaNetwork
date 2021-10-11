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
/// - urlRequestCache: The response is cached by HTTP Protocol.
/// - syMoyaNetworkCache: The response is cached in disk.

public enum NetworkCacheType {

    /// The Request is not cached yet when retrieving it.
    case none
    /// The Request is cached use HTTP Protocol
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
    
    /// Indicates whether to use URL for caching
    public var isUrlRequestCacheCase: Bool {
        switch self {
        case .urlRequestCache:
            return true
        default:
            return false
        }
    }
}
 
//MARK: - NetworkCacheOptionsInfo

public extension NetworkCacheType {
    
    static let defaultCacheKey: String = "com.shannonyang.SYMoyaNetwork.NetworkCache.Key"
    
    /// When the network type is changed to syMoyaNetworkCache, the cache information configuration category mainly includes diskStorageConfig configuration, memoryStorageConfig configuration, etc. Other cacheKeys have a default value, which can be modified by setting cacheKey
    
    struct NetworkCacheOptionsInfo {
        
        /// The default cache key
        public var cacheKey: String = defaultCacheKey
    
        /// Disk storage configuration. The default configuration is the configuration information in NetworkConfig
        public var diskStorageConfig: DiskStorage.Config
        
        /// Memory storage configuration.  The default configuration is the configuration information in NetworkConfig
        public var memoryStorageConfig: MemoryStorage.Config
 
        /// Create cache Option object
        /// - Parameters:
        ///   - cacheKey: Cached key, for example: "com.shannonyang.SYMoyaNetwork.NetworkCache.Key"
        ///   - diskStorageConfig: Disk storage configuration.
        ///   - memoryStorageConfig: Memory storage configuration.
        
        init(cacheKey: String = defaultCacheKey, diskStorageConfig: DiskStorage.Config = NetworkConfig.sharedInstance.networkCache.diskStorage.config, memoryStorageConfig: MemoryStorage.Config = NetworkConfig.sharedInstance.networkCache.memoryStorage.config) {
            self.cacheKey = cacheKey
            self.diskStorageConfig = diskStorageConfig
            self.memoryStorageConfig = memoryStorageConfig
        }
    }
}

//MARK: - URLCacheInfo

public extension NetworkCacheType {
    
    /// URL cache information, such as ignoreServer, maxAge, autoClearCache and other information
    
    struct URLCacheInfo {
        
        /// Indicates whether to ignore the server
        public let ignoreServer: Bool
        
        /// HTTP Version
        public var HTTPVersion: String {
            didSet {
                if self.HTTPVersion.contains("1.0") {
                    self.isCanUseCacheControl = false
                }
            }
        }
        
        private(set) var isCanUseCacheControl = true
        
        /// HTTP max-age attribute
        public var maxAge: Int
        
        /// Indicates whether it is private
        public var isPrivate: Bool = false
        
        ///
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



