//
//  NetworkConfig.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/7/14.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Default Log Configuation
public typealias LogConfiguration = SYMoyaNetworkLoggerPlugin.Configuration

// Network configuration object, you can configure network log and network cache objects by setting logConfiguration and networkCache
public struct NetworkConfig {
    /// Single Object
    public static var sharedInstance : NetworkConfig = NetworkConfig()
    
    /// Network log configuration object
    public var logConfiguration: LogConfiguration = NetworkConfig.defaultLogConfiguration()
    
    /// Network cache configuration object
    public var networkCache: NetworkCache = NetworkConfig.defaultNetworkCache()
}

// MARK: - Internal
extension NetworkConfig {
    /// Default log configuration object
    ///
    /// - Returns: Network request log print plugin object
   static func defaultLogConfiguration() -> LogConfiguration {
        return LogConfiguration()
    }

    /// Default cache object
    ///
    /// - Returns: Represents a hybrid caching system which is composed by a `MemoryStorage.Backend` and a `DiskStorage.Backend`.
    static func defaultNetworkCache() -> NetworkCache {
        return NetworkCache(name: "Default")
    }
}
