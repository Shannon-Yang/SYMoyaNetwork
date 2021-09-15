//
//  NetworkConfig.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/7/14.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public struct NetworkConfig {
    
    public typealias LogConfiguration = SYMoyaNetworkLoggerPlugin.Configuration
    
    public static let sharedInstance : NetworkConfig = NetworkConfig()

    public var logConfiguration: LogConfiguration = NetworkConfig.defaultLogConfiguration()
    
    public var networkCache: NetworkCache = NetworkConfig.defaultNetworkCache()
    
}

// MARK: - Private

extension NetworkConfig {
    
   static func defaultLogConfiguration() -> LogConfiguration {
        return LogConfiguration()
    }
    
    static func defaultNetworkCache() -> NetworkCache {
        return NetworkCache.default
    }

}
