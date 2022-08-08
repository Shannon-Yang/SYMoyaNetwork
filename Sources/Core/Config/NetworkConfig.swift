//
//  NetworkConfig.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/7/14.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

// Network configuration object, you can configure network log and network cache objects by setting logConfiguration and networkCache
public struct NetworkConfig {
    
    public typealias LogConfiguration = SYMoyaNetworkLoggerPlugin.Configuration
    
    public static var sharedInstance : NetworkConfig = NetworkConfig()

    /// Network log configuration object
    public var logConfiguration: LogConfiguration = NetworkConfig.defaultLogConfiguration()
    
    /// Network cache configuration object
    public var networkCache: NetworkCache = NetworkConfig.defaultNetworkCache()
    
}

// MARK: - Internal
extension NetworkConfig {
    
   static func defaultLogConfiguration() -> LogConfiguration {
        return LogConfiguration()
    }
    
    static func defaultNetworkCache() -> NetworkCache {
        return NetworkCache(name: "Default")
    }

}
