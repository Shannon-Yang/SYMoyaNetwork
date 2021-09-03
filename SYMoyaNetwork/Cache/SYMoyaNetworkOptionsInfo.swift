//
//  SYMoyaNetworkOptionsInfo.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/17.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
    

/// SYMoyaNetworkOptionsInfo is a typealias for [SYMoyaNetworkOptionsInfoItem].
/// You can use the enum of option item with value to control some behaviors of SYMoyaNetwork.
public typealias SYMoyaNetworkOptionsInfo = [SYMoyaNetworkOptionsInfoItem]

extension Array where Element == SYMoyaNetworkOptionsInfoItem {
    static let empty: SYMoyaNetworkOptionsInfo = []
}

/// Represents the available option items could be used in `SYMoyaNetworkOptionsInfo`.
public enum SYMoyaNetworkOptionsInfoItem {
    
    /// SYMoyaNetwork will use the associated `NetworkCache` object when handling related operations,
    /// including trying to retrieve the cached responses and store the downloaded response to it.
    case targetCache(NetworkCache)

    /// If set, SYMoyaNetwork will ignore the cache and try to start a download task for the response source.
    case forceRefresh
    
    /// If set, SYMoyaNetwork will only cache the value in memory but not in disk.
    case cacheMemoryOnly
    
    /// If set, SYMoyaNetwork will only try to retrieve the response from cache, but not from network. If the response is not in
    /// cache, the response retrieving will fail with the `SYMoyaNetworkError.cacheError` with `.responseNotExisting` as its
    /// reason.
    case onlyFromCache
    
    ///
    case providerSerializerType(ProviderSerializerType)

    /// The associated value will be used as the target queue of dispatch callbacks when retrieving responses from
    /// cache. If not set, SYMoyaNetwork will use `.mainCurrentOrAsync` for callbacks.
    ///
    /// - Note:
    /// This option does not affect the callbacks for UI related extension methods. You will always get the
    /// callbacks called from main queue.
    case callbackQueue(CallbackQueue)
    
    /// Provides a `CacheSerializer` to convert some data to an response object for
    /// retrieving from disk cache or vice versa for storing to disk cache.
    /// If not set, the `DefaultCacheSerializer.default` will be used.
    case cacheSerializer(CacheSerializer)
    
    /// If set, the disk storage loading will happen in the same calling queue. By default, disk storage file loading
    /// happens in its own queue with an asynchronous dispatch behavior. Although it provides better non-blocking disk
    /// loading performance, it also causes a flickering when you reload an response from disk, if the response view already
    /// has an response set.
    ///
    /// Set this options will stop that flickering by keeping all loading in the same queue (typically the UI queue
    /// if you are using SYMoyaNetwork's extension methods to set an response), with a tradeoff of loading performance.
    case loadDiskFileSynchronously
    
    /// The expiration setting for memory cache. By default, the underlying `MemoryStorage.Backend` uses the
    /// expiration in its config for all items. If set, the `MemoryStorage.Backend` will use this associated
    /// value to overwrite the config setting for this caching item.
    case memoryCacheExpiration(StorageExpiration)
    
    /// The expiration extending setting for memory cache. The item expiration time will be incremented by this
    /// value after access.
    /// By default, the underlying `MemoryStorage.Backend` uses the initial cache expiration as extending
    /// value: .cacheTime.
    ///
    /// To disable extending option at all add memoryCacheAccessExtendingExpiration(.none) to options.
    case memoryCacheAccessExtendingExpiration(ExpirationExtending)
    
    /// The expiration setting for disk cache. By default, the underlying `DiskStorage.Backend` uses the
    /// expiration in its config for all items. If set, the `DiskStorage.Backend` will use this associated
    /// value to overwrite the config setting for this caching item.
    case diskCacheExpiration(StorageExpiration)

    /// The expiration extending setting for disk cache. The item expiration time will be incremented by this value after access.
    /// By default, the underlying `DiskStorage.Backend` uses the initial cache expiration as extending value: .cacheTime.
    /// To disable extending option at all add diskCacheAccessExtendingExpiration(.none) to options.
    case diskCacheAccessExtendingExpiration(ExpirationExtending)
}

// Improve performance by parsing the input `SYMoyaNetworkOptionsInfo` (self) first.
// So we can prevent the iterating over the options array again and again.
/// The parsed options info used across SYMoyaNetwork methods. Each property in this type corresponds a case member
/// in `SYMoyaNetworkOptionsInfoItem`. When a `SYMoyaNetworkOptionsInfo` sent to SYMoyaNetwork related methods, it will be
/// parsed and converted to a `SYMoyaNetworkParsedOptionsInfo` first, and pass through the internal methods.
public struct SYMoyaNetworkParsedOptionsInfo {

    public var targetCache: NetworkCache? = nil
    public var forceRefresh = false
    public var fromMemoryCacheOrRefresh = false
    public var cacheMemoryOnly = false
    public var waitForCache = false
    public var onlyFromCache = false
    public var providerSerializerType: ProviderSerializerType = .data
    public var backgroundDecode = false
    public var preloadAllAnimationData = false
    public var callbackQueue: CallbackQueue = .mainCurrentOrAsync
    public var cacheSerializer: CacheSerializer = DefaultCacheSerializer.default
    public var onlyLoadFirstFrame = false
    public var alsoPrefetchToMemory = false
    public var loadDiskFileSynchronously = false
    public var memoryCacheExpiration: StorageExpiration? = nil
    public var memoryCacheAccessExtendingExpiration: ExpirationExtending = .cacheTime
    public var diskCacheExpiration: StorageExpiration? = nil
    public var diskCacheAccessExtendingExpiration: ExpirationExtending = .cacheTime
    
    public init(_ info: SYMoyaNetworkOptionsInfo?) {
        guard let info = info else { return }
        for option in info {
            switch option {
            case .targetCache(let value): targetCache = value
            case .forceRefresh: forceRefresh = true
            case .cacheMemoryOnly: cacheMemoryOnly = true
            case .onlyFromCache: onlyFromCache = true
            case .providerSerializerType(let type): providerSerializerType = type
            case .callbackQueue(let value): callbackQueue = value
            case .cacheSerializer(let value): cacheSerializer = value
            case .loadDiskFileSynchronously: loadDiskFileSynchronously = true
            case .memoryCacheExpiration(let expiration): memoryCacheExpiration = expiration
            case .memoryCacheAccessExtendingExpiration(let expirationExtending): memoryCacheAccessExtendingExpiration = expirationExtending
            case .diskCacheExpiration(let expiration): diskCacheExpiration = expiration
            case .diskCacheAccessExtendingExpiration(let expirationExtending): diskCacheAccessExtendingExpiration = expirationExtending
            }
        }
    }
}


