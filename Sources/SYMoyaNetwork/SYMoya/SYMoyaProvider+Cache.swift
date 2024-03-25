//
//  SYMoyaProvider+Cache.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/9/15.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

// MARK: - Cache

extension SYMoyaProvider {
    /// Generate cache key by `Target`
    ///
    /// - Parameter target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    /// - Returns: Generated cache key
    func generateCacheKey(_ target: Target) -> String {
        let urlString = URL(target: target).absoluteString
        var parametersString: String?
        if let httpBody = try? endpoint(target).urlRequest().httpBody {
            parametersString = String(decoding: httpBody, as: UTF8.self)
        }
        let method = target.method.rawValue
        let cacheKey = NetworkCacheType.defaultCacheKey
        var key = "\(cacheKey)+\(urlString)+\(method)"
        if let string = parametersString {
            key.append("+\(string)")
        }
        return key.md5()
    }

    /// Cache `Moya.Response` to Memory or Disk
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - response: Represents a response to a `MoyaProvider.request`.
    ///   - toDisk: Whether to cache to disk
    func cache(_ target: Target, response: Moya.Response, toDisk: Bool = true) {
        switch target.networkCacheType {
        case let .cache(info):
            // config
            cache.diskStorage.config = info.diskStorageConfig
            cache.memoryStorage.config = info.memoryStorageConfig
            if info.diskStorageConfig.expiration.isExpired {
                return
            }
            if response.data.isEmpty {
                return
            }
            if target.requestBaseURL().absoluteString.isEmpty {
                return
            }
            if target.path.isEmpty {
                return
            }
            if URL(target: target).absoluteString.isEmpty {
                return
            }
            let key = generateCacheKey(target)
            let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(cache), .diskCacheExpiration(.days(7)), .memoryCacheExpiration(.seconds(300))])
            cache.store(response, forKey: key, options: options, toDisk: toDisk) { result in
                if let diskResultDes = result.diskCacheResult.failure?.errorDescription {
                    // disk Cache Failure
                    print("\(diskResultDes)")
                }
            }
        case .none:
            break
        }
    }

    /// Gets an response for a given `Target` from the cache, either from memory storage or disk storage.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - options: The `SYMoyaNetworkParsedOptionsInfo` options setting used for retrieving the response.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is `.mainCurrentOrAsync`.
    ///   - completion: A closure which is invoked when the response getting operation finishes. If the
    ///                 response retrieving operation finishes without problem, an `NetworkCacheResult` value
    ///                 will be sent to this closure as result. Otherwise, a `SYMoyaNetworkError` result
    ///                 with detail failing reason will be sent.
    func retrieve(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ result: SYMoyaNetworkResult) -> Void) {
        let key = generateCacheKey(target)
        var queue = CallbackQueue.mainAsync
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        cache.retrieveResponse(forKey: key, options: options, callbackQueue: queue) { result in
            let resultResponse: SYMoyaNetworkResultResponse
            resultResponse.isDataFromCache = true
            switch result {
            case let .success(networkCacheResult):
                switch networkCacheResult {
                case let .memory(response):
                    resultResponse.response = response
                    completion(.success(resultResponse))
                case let .disk(response):
                    resultResponse.response = response
                    completion(.success(resultResponse))
                case .none:
                    // cache Not Existing
                    completion(.failure(.cacheError(reason: .responseNotExisting(key: key))))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /// Gets an response for a given `Target` from the memory storage.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - options: The `SYMoyaNetworkParsedOptionsInfo` options setting used for retrieving the response.
    /// - Returns: The response stored in memory cache, if exists and valid. Otherwise, if the response does not exist or
    ///            has already expired, `nil` is returned.
    func retrieveResponseInMemoryCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo) -> SYMoyaNetworkResult {
        let key = generateCacheKey(target)
        if let response = cache.retrieveResponseInMemoryCache(forKey: key, options: options) {
            let resultResponse = (response, true)
            return .success(resultResponse)
        }
        return .failure(SYMoyaNetworkError.cacheError(reason: .responseNotExisting(key: key)))
    }

    /// Gets an response for a given `Target` from the disk storage.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - options: The `SYMoyaNetworkOptionsInfo` options setting used for retrieving the response.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is `.mainCurrentOrAsync`.
    ///   - completionHandler: A closure which is invoked when the response getting operation finishes. If the
    ///                        response retrieving operation finishes without problem, an `NetworkCacheResult` value
    ///                        will be sent to this closure as result. Otherwise, a `SYMoyaNetworkError` result
    ///                        with detail failing reason will be sent.
    func retrieveResponseInDiskCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completionHandler: @escaping (SYMoyaNetworkResult) -> Void) {
        let key = generateCacheKey(target)
        var queue = CallbackQueue.mainAsync
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        cache.retrieveResponseInDiskCache(forKey: key, options: options, callbackQueue: queue, completionHandler: completionHandler)
    }

    /// Whether the `Target` needs to be cached
    ///
    /// This method will determine whether the current response needs to be cached based on the `memoryStorageConfig` and `diskStorageConfig` of the `Target`'s `networkCacheType` field.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - response: Represents a response to a `MoyaProvider.request`.
    func cacheIfNeeded(_ target: Target, response: Moya.Response) {
        // Cache
        switch target.networkCacheType {
        case let .cache(info):
            switch info.memoryStorageConfig.expiration {
            case .never, .expired:
                switch info.diskStorageConfig.expiration {
                case .expired, .never:
                    break
                default:
                    cache(target, response: response)
                }
            default:
                switch info.diskStorageConfig.expiration {
                case .expired, .never:
                    cache(target, response: response, toDisk: false)
                default:
                    cache(target, response: response)
                }
            }
        case .none:
            break
        }
    }
}

// MARK: - Cache Clean

extension SYMoyaProvider {
    /// Clears the memory & disk storage of this cache. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    /// This `handler` will be called from the main queue.
    public func clearCache(completion handler: (() -> Void)? = nil) {
        cache.clearCache(completion: handler)
    }

    /// Clears cached data in memory
    public func clearMemoryCache() {
        cache.clearMemoryCache()
    }

    /// Clears cached data from disk
    /// - Parameter handler: Callback method after clear is complete
    public func clearDiskCache(completion handler: (() -> Void)? = nil) {
        cache.clearDiskCache(completion: handler)
    }

    /// Clears expired cached data
    /// - Parameter handler: Callback method after clear is complete
    public func cleanExpiredCache(completion handler: (() -> Void)? = nil) {
        cache.cleanExpiredCache(completion: handler)
    }

    /// Clears the expired response from disk storage.
    public func cleanExpiredMemoryCache() {
        cache.cleanExpiredMemoryCache()
    }

    /// Clears the expired response from disk storage. This is an async operation.
    public func cleanExpiredDiskCache() {
        cache.cleanExpiredDiskCache()
    }

    /// Clears expired cached data
    /// - Parameter handler: Callback method after clear is complete
    public func cleanExpiredDiskCache(completion handler: (() -> Void)? = nil) {
        cache.cleanExpiredDiskCache(completion: handler)
    }
}
