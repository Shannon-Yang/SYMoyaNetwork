//
//  NetworkCacheFromType.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2024/3/19.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

///  Network cache retrieval type.
public enum NetworkCacheFromType {
    /// First retrieve the cache from memory, if it does not exist in memory, then retrieve the cache
    case memoryOrDisk
    /// Retrieve cache from disk
    case disk
    /// Retrieve cache from memory
    case memory
}
