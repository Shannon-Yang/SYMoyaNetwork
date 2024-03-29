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
    public static var sharedInstance: NetworkConfig = .init()

    /// Network log configuration object
    public var logConfiguration: LogConfiguration = Self.defaultLogConfiguration()

    /// Network cache configuration object
    public var networkCache: NetworkCache = Self.defaultNetworkCache()
}

// MARK: - Internal

extension NetworkConfig {
    /// Default log configuration object
    ///
    /// - Returns: Network request log print plugin object
    static func defaultLogConfiguration() -> LogConfiguration {
        LogConfiguration()
    }

    /// Default cache object
    ///
    /// - Returns: Represents a hybrid caching system which is composed by a `MemoryStorage.Backend` and a `DiskStorage.Backend`.
    static func defaultNetworkCache() -> NetworkCache {
        NetworkCache(name: "Default")
    }
}
