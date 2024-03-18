//
//  NetworkCacheType.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/18.
//  Copyright © 2023 Shannon Yang. All rights reserved.
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
    /// The Request is cached in disk or memory
    case cache(networkCacheOptionsInfo: NetworkCacheOptionsInfo = NetworkCacheOptionsInfo())

    /// Whether the cache type represents the Request is already cached or not.
    public var isUseCache: Bool {
        switch self {
        case .cache: return true
        case .none: return false
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
        public init(cacheKey: String = defaultCacheKey, diskStorageConfig: DiskStorage.Config = NetworkConfig.sharedInstance.networkCache.diskStorage.config, memoryStorageConfig: MemoryStorage.Config = NetworkConfig.sharedInstance.networkCache.memoryStorage.config) {
            self.cacheKey = cacheKey
            self.diskStorageConfig = diskStorageConfig
            self.memoryStorageConfig = memoryStorageConfig
        }
    }
}



