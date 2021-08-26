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
    

/// KingfisherOptionsInfo is a typealias for [KingfisherOptionsInfoItem].
/// You can use the enum of option item with value to control some behaviors of Kingfisher.
public typealias SYMoyaNetworkOptionsInfo = [SYMoyaNetworkOptionsInfoItem]

extension Array where Element == SYMoyaNetworkOptionsInfoItem {
    static let empty: SYMoyaNetworkOptionsInfo = []
}

/// Represents the available option items could be used in `KingfisherOptionsInfo`.
public enum SYMoyaNetworkOptionsInfoItem {
    
    /// Kingfisher will use the associated `ImageCache` object when handling related operations,
    /// including trying to retrieve the cached images and store the downloaded image to it.
    case targetCache(NetworkCache)

    /// If set, Kingfisher will ignore the cache and try to start a download task for the image source.
    case forceRefresh

    /// If set, Kingfisher will try to retrieve the image from memory cache first. If the image is not in memory
    /// cache, then it will ignore the disk cache but download the image again from network. This is useful when
    /// you want to display a changeable image behind the same url at the same app session, while avoiding download
    /// it for multiple times.
    case fromMemoryCacheOrRefresh
    
    /// If set, Kingfisher will only cache the value in memory but not in disk.
    case cacheMemoryOnly
    
    /// If set, Kingfisher will wait for caching operation to be completed before calling the completion block.
    case waitForCache
    
    /// If set, Kingfisher will only try to retrieve the image from cache, but not from network. If the image is not in
    /// cache, the image retrieving will fail with the `KingfisherError.cacheError` with `.imageNotExisting` as its
    /// reason.
    case onlyFromCache

    /// The associated value will be used as the target queue of dispatch callbacks when retrieving images from
    /// cache. If not set, Kingfisher will use `.mainCurrentOrAsync` for callbacks.
    ///
    /// - Note:
    /// This option does not affect the callbacks for UI related extension methods. You will always get the
    /// callbacks called from main queue.
    case callbackQueue(CallbackQueue)
    
    /// Provides a `CacheSerializer` to convert some data to an image object for
    /// retrieving from disk cache or vice versa for storing to disk cache.
    /// If not set, the `DefaultCacheSerializer.default` will be used.
    case cacheSerializer(CacheSerializer)
    
    /// If set and used in `ImagePrefetcher`, the prefetching operation will load the images into memory storage
    /// aggressively. By default this is not contained in the options, that means if the requested image is already
    /// in disk cache, Kingfisher will not try to load it to memory.
    case alsoPrefetchToMemory
    
    /// If set, the disk storage loading will happen in the same calling queue. By default, disk storage file loading
    /// happens in its own queue with an asynchronous dispatch behavior. Although it provides better non-blocking disk
    /// loading performance, it also causes a flickering when you reload an image from disk, if the image view already
    /// has an image set.
    ///
    /// Set this options will stop that flickering by keeping all loading in the same queue (typically the UI queue
    /// if you are using Kingfisher's extension methods to set an image), with a tradeoff of loading performance.
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

// Improve performance by parsing the input `KingfisherOptionsInfo` (self) first.
// So we can prevent the iterating over the options array again and again.
/// The parsed options info used across Kingfisher methods. Each property in this type corresponds a case member
/// in `KingfisherOptionsInfoItem`. When a `KingfisherOptionsInfo` sent to Kingfisher related methods, it will be
/// parsed and converted to a `KingfisherParsedOptionsInfo` first, and pass through the internal methods.
public struct SYMoyaNetworkParsedOptionsInfo {

    public var targetCache: NetworkCache? = nil
    public var forceRefresh = false
    public var fromMemoryCacheOrRefresh = false
    public var forceTransition = false
    public var cacheMemoryOnly = false
    public var waitForCache = false
    public var onlyFromCache = false
    public var backgroundDecode = false
    public var preloadAllAnimationData = false
    public var callbackQueue: CallbackQueue = .mainCurrentOrAsync
    public var scaleFactor: CGFloat = 1.0
    public var cacheSerializer: CacheSerializer = DefaultCacheSerializer.default
    public var keepCurrentImageWhileLoading = false
    public var onlyLoadFirstFrame = false
    public var cacheOriginalImage = false
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
            case .fromMemoryCacheOrRefresh: fromMemoryCacheOrRefresh = true
            case .cacheMemoryOnly: cacheMemoryOnly = true
            case .waitForCache: waitForCache = true
            case .onlyFromCache: onlyFromCache = true
            case .callbackQueue(let value): callbackQueue = value
            case .cacheSerializer(let value): cacheSerializer = value
            case .alsoPrefetchToMemory: alsoPrefetchToMemory = true
            case .loadDiskFileSynchronously: loadDiskFileSynchronously = true
            case .memoryCacheExpiration(let expiration): memoryCacheExpiration = expiration
            case .memoryCacheAccessExtendingExpiration(let expirationExtending): memoryCacheAccessExtendingExpiration = expirationExtending
            case .diskCacheExpiration(let expiration): diskCacheExpiration = expiration
            case .diskCacheAccessExtendingExpiration(let expirationExtending): diskCacheAccessExtendingExpiration = expirationExtending
            }
        }
    }
}


