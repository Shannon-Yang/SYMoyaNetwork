//
//  NetworkConfig.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/7/14.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

struct NetworkConfig {
    
    typealias LogConfiguration = Moya.NetworkLoggerPlugin.Configuration
    
    var debugLogEnabled: Bool = true
    
    
    var logConfiguration: LogConfiguration
    
    
    var diskCacheConfig: DiskStorage.Config
    
    var memoryCacheConfig: MemoryStorage.Config
}


//public extension NetworkLoggerPlugin.Configuration.LogOptions {
//
//
//}

// MARK: - Private

private extension NetworkConfig {
    
    func defaultCacheConfig() {
        // TODO: Shannon Yang 👺
    }
}
