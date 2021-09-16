//
//  NetworkCache.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/18.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import Moya

extension Notification.Name {

    public static let SYMoyaNetworkDidCleanDiskCache =
        Notification.Name("com.shannonyang.SYMoyaNetwork.SYMoyaNetworkDidCleanDiskCache")
}

/// Key for array of cleaned hashes in `userInfo` of `SYMoyaNetworkDidCleanDiskCacheNotification`.
public let SYMoyaNetworkDiskCacheCleanedHashKey = "com.shannonyang.SYMoyaNetwork.cleanedHash"

/// Cache type of a cached Response.
/// - none: The Response is not cached yet when retrieving it.
/// - memory: The Response is cached in memory.
/// - disk: The Response is cached in disk.
public enum CacheType {
    /// The Response is not cached yet when retrieving it.
    case none
    /// The Response is cached in memory.
    case memory
    /// The Response is cached in disk.
    case disk
    
    /// Whether the cache type represents the Response is already cached or not.
    public var cached: Bool {
        switch self {
        case .memory, .disk: return true
        case .none: return false
        }
    }
}

/// Represents the caching operation result.
public struct CacheStoreResult {
    
    /// The cache result for memory cache. Caching an Response to memory will never fail.
    public let memoryCacheResult: Result<(), Never>
    
    /// The cache result for disk cache. If an error happens during caching operation,
    /// you can get it from `.failure` case of this `diskCacheResult`.
    public let diskCacheResult: Result<(), SYMoyaNetworkError>
}

extension Data: DataTransformable {
    public func toData() throws -> Data {
        return self
    }

    public static func fromData(_ data: Data) throws -> Data {
        return data
    }

    public static let empty = Data()
}


/// Represents the getting Response operation from the cache.
///
/// - disk: The Response can be retrieved from disk cache.
/// - memory: The Response can be retrieved memory cache.
/// - none: The Response does not exist in the cache.
public enum NetworkCacheResult {
    
    /// The Moya.Response can be retrieved from disk cache.
    case disk(Moya.Response)
    
    /// The Moya.Response can be retrieved memory cache.
    case memory(Moya.Response)
    
    /// The Moya.Response does not exist in the cache.
    case none
    
    /// Extracts the Moya.Response from cache result. It returns the associated `Response` value for
    /// `.disk` and `.memory` case. For `.none` case, `nil` is returned.
    public var response: Moya.Response? {
        switch self {
        case .disk(let response): return response
        case .memory(let response): return response
        case .none: return nil
        }
    }
    
    /// Returns the corresponding `CacheType` value based on the result type of `self`.
    public var cacheType: CacheType {
        switch self {
        case .disk: return .disk
        case .memory: return .memory
        case .none: return .none
        }
    }
}

/// Represents a hybrid caching system which is composed by a `MemoryStorage.Backend` and a `DiskStorage.Backend`.
/// `NetworkCache` is a high level abstract for storing an Moya.Response as well as its data to disk memory and disk, and
/// retrieving them back.
///
/// While a default Moya.Response cache object will be used if you prefer the extension methods of SYMoyaNetwork, you can create
/// your own cache object and configure its storages as your need. This class also provide an interface for you to set
/// the memory and disk storage config.
open class NetworkCache {

    // MARK: Singleton
    /// The default `NetworkCache` object. SYMoyaNetwork will use this cache for its related methods if there is no
    /// other cache specified. The `name` of this default cache is "default", and you should not use this name
    /// for any of your customize cache.
    public static let `default` = NetworkCache(name: "default")


    // MARK: Public Properties
    /// The `MemoryStorage.Backend` object used in this cache. This storage holds loaded Moya.Response in memory with a
    /// reasonable expire duration and a maximum memory usage. To modify the configuration of a storage, just set
    /// the storage `config` and its properties.
    public let memoryStorage: MemoryStorage.Backend<Moya.Response>
    
    /// The `DiskStorage.Backend` object used in this cache. This storage stores loaded Moya.Response in disk with a
    /// reasonable expire duration and a maximum disk usage. To modify the configuration of a storage, just set
    /// the storage `config` and its properties.
    public let diskStorage: DiskStorage.Backend<Data>
    
    private let ioQueue: DispatchQueue
    
    /// Closure that defines the disk cache path from a given path and cacheName.
    public typealias DiskCachePathClosure = (URL, String) -> URL

    // MARK: Initializers

    /// Creates an `NetworkCache` from a customized `MemoryStorage` and `DiskStorage`.
    ///
    /// - Parameters:
    ///   - memoryStorage: The `MemoryStorage.Backend` object to use in the Moya.Response cache.
    ///   - diskStorage: The `DiskStorage.Backend` object to use in the Moya.Response cache.
    public init(
        memoryStorage: MemoryStorage.Backend<Moya.Response>,
        diskStorage: DiskStorage.Backend<Data>)
    {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
        let ioQueueName = "com.shannonyang.SYMoyaNetwork.NetworkCache.ioQueue.\(UUID().uuidString)"
        ioQueue = DispatchQueue(label: ioQueueName)

        let notifications: [(Notification.Name, Selector)]
        #if !os(macOS) && !os(watchOS)
        notifications = [
            (UIApplication.didReceiveMemoryWarningNotification, #selector(clearMemoryCache)),
            (UIApplication.willTerminateNotification, #selector(cleanExpiredDiskCache)),
            (UIApplication.didEnterBackgroundNotification, #selector(backgroundCleanExpiredDiskCache))
        ]
        #elseif os(macOS)
        notifications = [
            (NSApplication.willResignActiveNotification, #selector(cleanExpiredDiskCache)),
        ]
        #else
        notifications = []
        #endif
        notifications.forEach {
            NotificationCenter.default.addObserver(self, selector: $0.1, name: $0.0, object: nil)
        }
    }
    
    /// Creates an `NetworkCache` with a given `name`. Both `MemoryStorage` and `DiskStorage` will be created
    /// with a default config based on the `name`.
    ///
    /// - Parameter name: The name of cache object. It is used to setup disk cache directories and IO queue.
    ///                   You should not use the same `name` for different caches, otherwise, the disk storage would
    ///                   be conflicting to each other. The `name` should not be an empty string.
    public convenience init(name: String) {
        self.init(noThrowName: name, cacheDirectoryURL: nil, diskCachePathClosure: nil)
    }

    /// Creates an `NetworkCache` with a given `name`, cache directory `path`
    /// and a closure to modify the cache directory.
    ///
    /// - Parameters:
    ///   - name: The name of cache object. It is used to setup disk cache directories and IO queue.
    ///           You should not use the same `name` for different caches, otherwise, the disk storage would
    ///           be conflicting to each other.
    ///   - cacheDirectoryURL: Location of cache directory URL on disk. It will be internally pass to the
    ///                        initializer of `DiskStorage` as the disk cache directory. If `nil`, the cache
    ///                        directory under user domain mask will be used.
    ///   - diskCachePathClosure: Closure that takes in an optional initial path string and generates
    ///                           the final disk cache path. You could use it to fully customize your cache path.
    /// - Throws: An error that happens during response cache creating, such as unable to create a directory at the given
    ///           path.
    public convenience init(
        name: String,
        cacheDirectoryURL: URL?,
        diskCachePathClosure: DiskCachePathClosure? = nil) throws {
        if name.isEmpty {
            fatalError("[SYMoyaNetwork] You should specify a name for the cache. A cache with empty name is not permitted.")
        }

        let memoryStorage = NetworkCache.createMemoryStorage()

        let config = NetworkCache.createConfig(
            name: name, cacheDirectoryURL: cacheDirectoryURL, diskCachePathClosure: diskCachePathClosure
        )
        let diskStorage = try DiskStorage.Backend<Data>(config: config)
        self.init(memoryStorage: memoryStorage, diskStorage: diskStorage)
    }

    convenience init(
        noThrowName name: String,
        cacheDirectoryURL: URL?,
        diskCachePathClosure: DiskCachePathClosure?){
        if name.isEmpty {
            fatalError("[SYMoyaNetwork] You should specify a name for the cache. A cache with empty name is not permitted.")
        }

        let memoryStorage = NetworkCache.createMemoryStorage()

        let config = NetworkCache.createConfig(
            name: name, cacheDirectoryURL: cacheDirectoryURL, diskCachePathClosure: diskCachePathClosure
        )
        let diskStorage = DiskStorage.Backend<Data>(noThrowConfig: config, creatingDirectory: true)
        self.init(memoryStorage: memoryStorage, diskStorage: diskStorage)
    }

    private static func createMemoryStorage() -> MemoryStorage.Backend<Moya.Response> {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4
        let memoryStorage = MemoryStorage.Backend<Moya.Response>(config:
            .init(totalCostLimit: (costLimit > Int.max) ? Int.max : Int(costLimit)))
        return memoryStorage
    }

    private static func createConfig(
        name: String,
        cacheDirectoryURL: URL?,
        diskCachePathClosure: DiskCachePathClosure? = nil
    ) -> DiskStorage.Config
    {
        var diskConfig = DiskStorage.Config(
            name: name,
            sizeLimit: 0,
            directory: cacheDirectoryURL
        )
        if let closure = diskCachePathClosure {
            diskConfig.cachePathBlock = closure
        }
        return diskConfig
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Storing Response

    open func store(_ response: Moya.Response,
                    forKey key: String,
                    options: SYMoyaNetworkParsedOptionsInfo,
                    toDisk: Bool = true,
                    completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        let callbackQueue = options.callbackQueue

        // Memory storage should not throw.
        memoryStorage.storeNoThrow(value: response, forKey: key, expiration: options.memoryCacheExpiration)
        
        guard toDisk else {
            if let completionHandler = completionHandler {
                let result = CacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .success(()))
                callbackQueue.execute { completionHandler(result) }
            }
            return
        }
        
        ioQueue.async {
            let serializer = options.cacheSerializer
            let data = serializer.data(with: response)
            if data.isEmpty {
                guard let completionHandler = completionHandler else { return }
                
                let diskError = SYMoyaNetworkError.cacheError(
                    reason: .cannotSerializeResponse(response: response, serializer: serializer))
                let result = CacheStoreResult(
                    memoryCacheResult: .success(()),
                    diskCacheResult: .failure(diskError))
                callbackQueue.execute { completionHandler(result) }
            } else {
                self.syncStoreToDisk(
                    data,
                    forKey: key,
                    callbackQueue: callbackQueue,
                    expiration: options.diskCacheExpiration,
                    completionHandler: completionHandler)
            }
        }
    }

    /// Stores an response to the cache.
    ///
    /// - Parameters:
    ///   - response: The response to be stored.
    ///   - key: The key used for caching the response.
    ///   - identifier: The identifier of processor being used for caching. If you are using a processor for the
    ///                 response, pass the identifier of processor to this parameter.
    ///   - serializer: The `CacheSerializer`
    ///   - toDisk: Whether this response should be cached to disk or not. If `false`, the response is only cached in memory.
    ///             Otherwise, it is cached in both memory storage and disk storage. Default is `true`.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is `.untouch`. For case
    ///                    that `toDisk` is `false`, a `.untouch` queue means `callbackQueue` will be invoked from the
    ///                    caller queue of this method. If `toDisk` is `true`, the `completionHandler` will be called
    ///                    from an internal file IO queue. To change this behavior, specify another `CallbackQueue`
    ///                    value.
    ///   - completionHandler: A closure which is invoked when the cache operation finishes.
    open func store(_ response: Moya.Response,
                      forKey key: String,
                      cacheSerializer serializer: CacheSerializer = DefaultCacheSerializer.default,
                      toDisk: Bool = true,
                      callbackQueue: CallbackQueue = .untouch,
                      completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        let options = SYMoyaNetworkParsedOptionsInfo([
            .cacheSerializer(serializer),
            .callbackQueue(callbackQueue)
        ])
        store(response, forKey: key, options: options,
              toDisk: toDisk, completionHandler: completionHandler)
    }
    
    open func storeToDisk(
        _ data: Data,
        forKey key: String,
        processorIdentifier identifier: String = "",
        expiration: StorageExpiration? = nil,
        callbackQueue: CallbackQueue = .untouch,
        completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        ioQueue.async {
            self.syncStoreToDisk(
                data,
                forKey: key,
                callbackQueue: callbackQueue,
                expiration: expiration,
                completionHandler: completionHandler)
        }
    }
    
    private func syncStoreToDisk(
        _ data: Data,
        forKey key: String,
        callbackQueue: CallbackQueue = .untouch,
        expiration: StorageExpiration? = nil,
        completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        let result: CacheStoreResult
        do {
            try self.diskStorage.store(value: data, forKey: key, expiration: expiration)
            result = CacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .success(()))
        } catch {
            let diskError: SYMoyaNetworkError
            if let error = error as? SYMoyaNetworkError {
                diskError = error
            } else {
                diskError = .cacheError(reason: .cannotConvertToData(object: data, error: error))
            }
            
            result = CacheStoreResult(
                memoryCacheResult: .success(()),
                diskCacheResult: .failure(diskError)
            )
        }
        if let completionHandler = completionHandler {
            callbackQueue.execute { completionHandler(result) }
        }
    }

    // MARK: Removing Responses

    /// Removes the response for the given key from the cache.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    ///   - identifier: The identifier of processor being used for caching. If you are using a processor for the
    ///                 response, pass the identifier of processor to this parameter.
    ///   - fromMemory: Whether this response should be removed from memory storage or not.
    ///                 If `false`, the response won't be removed from the memory storage. Default is `true`.
    ///   - fromDisk: Whether this response should be removed from disk storage or not.
    ///               If `false`, the response won't be removed from the disk storage. Default is `true`.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is `.untouch`.
    ///   - completionHandler: A closure which is invoked when the cache removing operation finishes.
    open func removeResponse(forKey key: String,
                          fromMemory: Bool = true,
                          fromDisk: Bool = true,
                          callbackQueue: CallbackQueue = .untouch,
                          completionHandler: (() -> Void)? = nil)
    {
        if fromMemory {
            memoryStorage.remove(forKey: key)
        }
        
        if fromDisk {
            ioQueue.async{
                try? self.diskStorage.remove(forKey: key)
                if let completionHandler = completionHandler {
                    callbackQueue.execute { completionHandler() }
                }
            }
        } else {
            if let completionHandler = completionHandler {
                callbackQueue.execute { completionHandler() }
            }
        }
    }

    // MARK: Getting Responses

    /// Gets an response for a given key from the cache, either from memory storage or disk storage.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    ///   - options: The `SYMoyaNetworkParsedOptionsInfo` options setting used for retrieving the response.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is `.mainCurrentOrAsync`.
    ///   - completionHandler: A closure which is invoked when the response getting operation finishes. If the
    ///                        response retrieving operation finishes without problem, an `NetworkCacheResult` value
    ///                        will be sent to this closure as result. Otherwise, a `SYMoyaNetworkError` result
    ///                        with detail failing reason will be sent.
    open func retrieveResponse(
        forKey key: String,
        options: SYMoyaNetworkParsedOptionsInfo,
        callbackQueue: CallbackQueue = .mainCurrentOrAsync,
        completionHandler: ((Result<NetworkCacheResult, SYMoyaNetworkError>) -> Void)?)
    {
        // No completion handler. No need to start working and early return.
        guard let completionHandler = completionHandler else { return }

        // Try to check the response from memory cache first.
        if let response = retrieveResponseInMemoryCache(forKey: key, options: options) {
            callbackQueue.execute { completionHandler(.success(.memory(response))) }
        } else if options.fromMemoryCacheOrRefresh {
            callbackQueue.execute { completionHandler(.success(.none)) }
        } else {

            // Begin to disk search.
            self.retrieveResponseInDiskCache(forKey: key, options: options, callbackQueue: callbackQueue) {
                result in
                switch result {
                case .success(let response):

//                    guard let response = response else {
//                        // No response found in disk storage.
//                        callbackQueue.execute { completionHandler(.success(.none)) }
//                        return
//                    }

                    // Cache the disk response to memory.
                    // We are passing `false` to `toDisk`, the memory cache does not change
                    // callback queue, we can call `completionHandler` without another dispatch.
                    var cacheOptions = options
                    cacheOptions.callbackQueue = .untouch
                    self.store(
                        response,
                        forKey: key,
                        options: cacheOptions,
                        toDisk: false)
                    {
                        _ in
                        callbackQueue.execute { completionHandler(.success(.disk(response))) }
                    }
                case .failure(let error):
                    callbackQueue.execute { completionHandler(.failure(error)) }
                }
            }
        }
    }

    /// Gets an response for a given key from the cache, either from memory storage or disk storage.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    ///   - options: The `SYMoyaNetworkOptionsInfo` options setting used for retrieving the response.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is `.mainCurrentOrAsync`.
    ///   - completionHandler: A closure which is invoked when the response getting operation finishes. If the
    ///                        response retrieving operation finishes without problem, an `NetworkCacheResult` value
    ///                        will be sent to this closure as result. Otherwise, a `SYMoyaNetworkError` result
    ///                        with detail failing reason will be sent.
    ///
    /// Note: This method is marked as `open` for only compatible purpose. Do not overide this method. Instead, override
    ///       the version receives `SYMoyaNetworkParsedOptionsInfo` instead.
    open func retrieveResponse(forKey key: String,
                               options: SYMoyaNetworkOptionsInfo? = nil,
                        callbackQueue: CallbackQueue = .mainCurrentOrAsync,
                     completionHandler: ((Result<NetworkCacheResult, SYMoyaNetworkError>) -> Void)?)
    {
        retrieveResponse(
            forKey: key,
            options: SYMoyaNetworkParsedOptionsInfo(options),
            callbackQueue: callbackQueue,
            completionHandler: completionHandler)
    }

    /// Gets an response for a given key from the memory storage.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    ///   - options: The `SYMoyaNetworkParsedOptionsInfo` options setting used for retrieving the response.
    /// - Returns: The response stored in memory cache, if exists and valid. Otherwise, if the response does not exist or
    ///            has already expired, `nil` is returned.
    open func retrieveResponseInMemoryCache(
        forKey key: String,
        options: SYMoyaNetworkParsedOptionsInfo) -> Moya.Response?
    {
        return memoryStorage.value(forKey: key, extendingExpiration: options.memoryCacheAccessExtendingExpiration)
    }

    /// Gets an response for a given key from the memory storage.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    ///   - options: The `SYMoyaNetworkOptionsInfo` options setting used for retrieving the response.
    /// - Returns: The response stored in memory cache, if exists and valid. Otherwise, if the response does not exist or
    ///            has already expired, `nil` is returned.
    ///
    /// Note: This method is marked as `open` for only compatible purpose. Do not overide this method. Instead, override
    ///       the version receives `SYMoyaNetworkParsedOptionsInfo` instead.
    open func retrieveResponseInMemoryCache(
        forKey key: String,
        options: SYMoyaNetworkOptionsInfo? = nil) -> Moya.Response?
    {
        return retrieveResponseInMemoryCache(forKey: key, options: SYMoyaNetworkParsedOptionsInfo(options))
    }

    func retrieveResponseInDiskCache(
        forKey key: String,
        options: SYMoyaNetworkParsedOptionsInfo,
        callbackQueue: CallbackQueue = .untouch,
        completionHandler: @escaping (Result<Moya.Response, SYMoyaNetworkError>) -> Void)
    {
        let loadingQueue: CallbackQueue = options.loadDiskFileSynchronously ? .untouch : .dispatch(ioQueue)
        loadingQueue.execute {
            do {
                if let data = try self.diskStorage.value(forKey: key, extendingExpiration: options.diskCacheAccessExtendingExpiration) {
                    let response = options.cacheSerializer.response(with: 0, data: data, request: nil, response: nil, options: options)
                    callbackQueue.execute { completionHandler(.success(response)) }
                } else {
                    let error = SYMoyaNetworkError.cacheError(reason: .responseNotExisting(key: key))
                    callbackQueue.execute { completionHandler(.failure(error)) }
                }
            } catch {
                if let error = error as? SYMoyaNetworkError {
                    callbackQueue.execute { completionHandler(.failure(error)) }
                } else {
                    assertionFailure("The internal thrown error should be a `SYMoyaNetworkError`.")
                }
            }
        }
    }
    
    /// Gets an response for a given key from the disk storage.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    ///   - options: The `SYMoyaNetworkOptionsInfo` options setting used for retrieving the response.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is `.untouch`.
    ///   - completionHandler: A closure which is invoked when the operation finishes.
    open func retrieveResponseInDiskCache(
        forKey key: String,
        options: SYMoyaNetworkOptionsInfo? = nil,
        callbackQueue: CallbackQueue = .untouch,
        completionHandler: @escaping (Result<Moya.Response, SYMoyaNetworkError>) -> Void)
    {
        retrieveResponseInDiskCache(
            forKey: key,
            options: SYMoyaNetworkParsedOptionsInfo(options),
            callbackQueue: callbackQueue,
            completionHandler: completionHandler)
    }

    // MARK: Cleaning
    /// Clears the memory & disk storage of this cache. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    ///                      This `handler` will be called from the main queue.
    public func clearCache(completion handler: (() -> Void)? = nil) {
        clearMemoryCache()
        clearDiskCache(completion: handler)
    }
    
    /// Clears the memory storage of this cache.
    @objc public func clearMemoryCache() {
        memoryStorage.removeAll()
    }
    
    /// Clears the disk storage of this cache. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    ///                      This `handler` will be called from the main queue.
    open func clearDiskCache(completion handler: (() -> Void)? = nil) {
        ioQueue.async {
            do {
                try self.diskStorage.removeAll()
            } catch _ { }
            if let handler = handler {
                DispatchQueue.main.async { handler() }
            }
        }
    }
    
    /// Clears the expired response from memory & disk storage. This is an async operation.
    open func cleanExpiredCache(completion handler: (() -> Void)? = nil) {
        cleanExpiredMemoryCache()
        cleanExpiredDiskCache(completion: handler)
    }

    /// Clears the expired response from disk storage.
    open func cleanExpiredMemoryCache() {
        memoryStorage.removeExpired()
    }
    
    /// Clears the expired response from disk storage. This is an async operation.
    @objc func cleanExpiredDiskCache() {
        cleanExpiredDiskCache(completion: nil)
    }

    /// Clears the expired response from disk storage. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    ///                      This `handler` will be called from the main queue.
    open func cleanExpiredDiskCache(completion handler: (() -> Void)? = nil) {
        ioQueue.async {
            do {
                var removed: [URL] = []
                let removedExpired = try self.diskStorage.removeExpiredValues()
                removed.append(contentsOf: removedExpired)

                let removedSizeExceeded = try self.diskStorage.removeSizeExceededValues()
                removed.append(contentsOf: removedSizeExceeded)

                if !removed.isEmpty {
                    DispatchQueue.main.async {
                        let cleanedHashes = removed.map { $0.lastPathComponent }
                        NotificationCenter.default.post(
                            name: .SYMoyaNetworkDidCleanDiskCache,
                            object: self,
                            userInfo: [SYMoyaNetworkDiskCacheCleanedHashKey: cleanedHashes])
                    }
                }

                if let handler = handler {
                    DispatchQueue.main.async { handler() }
                }
            } catch {}
        }
    }

#if !os(macOS) && !os(watchOS)
    /// Clears the expired response from disk storage when app is in background. This is an async operation.
    /// In most cases, you should not call this method explicitly.
    /// It will be called automatically when `UIApplicationDidEnterBackgroundNotification` received.
    @objc public func backgroundCleanExpiredDiskCache() {
        let sharedApplication = UIApplication.shared
        func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
            sharedApplication.endBackgroundTask(task)
            task = UIBackgroundTaskIdentifier.invalid
        }
        
        var backgroundTask: UIBackgroundTaskIdentifier!
        backgroundTask = sharedApplication.beginBackgroundTask {
            endBackgroundTask(&backgroundTask!)
        }
        
        cleanExpiredDiskCache {
            endBackgroundTask(&backgroundTask!)
        }
    }
#endif

    // MARK: Response Cache State

    /// Returns the cache type for a given `key` and `identifier` combination.
    /// This method is used for checking whether an response is cached in current cache.
    /// It also provides information on which kind of cache can it be found in the return value.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    /// - Returns: A `CacheType` instance which indicates the cache status.
    ///            `.none` means the response is not in cache or it is already expired.
    open func responseCachedType(
        forKey key: String) -> CacheType
    {
        if memoryStorage.isCached(forKey: key) { return .memory }
        if diskStorage.isCached(forKey: key) { return .disk }
        return .none
    }
    
    /// Returns whether the file exists in cache for a given `key` combination.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    /// - Returns: A `Bool` which indicates whether a cache could match the given `key` combination.
    ///
    /// - Note:
    /// The return value does not contain information about from which kind of storage the cache matches.
    /// To get the information about cache type according `CacheType`,
    /// use `responseCachedType(forKey:processorIdentifier:)` instead.
    public func isCached(
        forKey key: String) -> Bool
    {
        return responseCachedType(forKey: key).cached
    }
    
    /// Gets the hash used as cache file name for the key.
    ///
    /// - Parameters:
    ///   - key: The key used for caching the response.
    /// - Returns: The hash which is used as the cache file name.
    ///
    /// - Note:
    /// By default, for a given combination of `key`, `NetworkCache` will use the value
    /// returned by this method as the cache file name. You can use this value to check and match cache file
    /// if you need.
    open func hash(
        forKey key: String) -> String
    {
        return diskStorage.cacheFileName(forKey: key)
    }
    
    /// Calculates the size taken by the disk storage.
    /// It is the total file size of all cached files in the `diskStorage` on disk in bytes.
    ///
    /// - Parameter handler: Called with the size calculating finishes. This closure is invoked from the main queue.
    open func calculateDiskStorageSize(completion handler: @escaping ((Result<UInt, SYMoyaNetworkError>) -> Void)) {
        ioQueue.async {
            do {
                let size = try self.diskStorage.totalSize()
                DispatchQueue.main.async { handler(.success(size)) }
            } catch {
                if let error = error as? SYMoyaNetworkError {
                    DispatchQueue.main.async { handler(.failure(error)) }
                } else {
                    assertionFailure("The internal thrown error should be a `SYMoyaNetworkError`.")
                }
                
            }
        }
    }
    
    /// Gets the cache path for the key.
    /// - Parameters:
    ///   - key: The key used for caching the response.
    /// - Returns: The disk path of cached response under the given `key`
    ///
    /// - Note:
    /// This method does not guarantee there is an response already cached in the returned path. It just gives your
    /// the path that the response should be, if it exists in disk storage.
    ///
    /// You could use `isCached(forKey:)` method to check whether the response is cached under that key in disk.
    open func cachePath(
        forKey key: String) -> String
    {
        return diskStorage.cacheFileURL(forKey: key).path
    }
}

extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore: (Value, Value) -> Bool) -> [Key] {
        return Array(self).sorted{ isOrderedBefore($0.1, $1.1) }.map{ $0.0 }
    }
}
