//
//  Cache.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/18.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation


public typealias caca = URLRequest.CachePolicy



public enum CachePolicy : UInt {

    /*
     
     服务器返回的响应头中会有这样的字段：Cache-Control: max-age or Cache-Control: s- maxage，通过Cache-Control来指定缓存策略，max-age来表示过期时间。根据这些字段缓存机制再采用如下策略：

     如果本地没有缓存数据，则进行网络请求。
     如果本地有缓存，并且缓存没有失效，则使用缓存。
     如果缓存已经失效，则询问服务器数据是否改变，如果没改变，依然使用缓存，如果改变了则请求新数据。
     如果没有指定是否失效，那么系统将自己判断缓存是否失效。（通常认为是6-24小时的有效时间）
     
     */
    
    case useProtocolCachePolicy = 0 // 默认值，根据http协议进行缓存

    
    case reloadIgnoringLocalCacheData = 1 // 不使用缓存数据，忽略缓存

    case reloadIgnoringLocalAndRemoteCacheData = 4 // Unimplemented

//    public static var reloadIgnoringCacheData: NSURLRequest.CachePolicy { get }

    
    case returnCacheDataElseLoad = 2 // 无论缓存是否过期都是用缓存，没有缓存就进行网络请求

    case returnCacheDataDontLoad = 3  // 无论缓存是否过期都是用缓存，没有缓存也不会进行网络请求

    
    case reloadRevalidatingCacheData = 5 // Unimplemented
}


/// Cache type of a cached image.
/// - none: The image is not cached yet when retrieving it.
/// - memory: The image is cached in memory.
/// - disk: The image is cached in disk.
//public enum CacheType {
//    /// The image is not cached yet when retrieving it.
//    case none
//    /// The image is cached in memory.
//    case memory
//    /// The image is cached in disk.
//    case disk
//
//    /// Whether the cache type represents the image is already cached or not.
//    public var cached: Bool {
//        switch self {
//        case .memory, .disk: return true
//        case .none: return false
//        }
//    }
//}
