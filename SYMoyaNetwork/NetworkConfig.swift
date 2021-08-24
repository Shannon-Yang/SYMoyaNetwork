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
    
}


//public extension NetworkLoggerPlugin.Configuration.LogOptions {
//
//
//}
