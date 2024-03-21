//
//  SYMoyaProvider+Cache.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/9/15.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - Cache
extension SYMoyaProvider {
    /// Generate cache key by target
    ///
    /// - Parameter target: <#target description#>
    /// - Returns: <#description#>
    func generateCacheKey(_ target: Target) -> String {
        let urlString = URL(target: target).absoluteString
        var parametersString: String?
        if let httpBody = try? self.endpoint(target).urlRequest().httpBody {
            parametersString = String(decoding: httpBody, as: UTF8.self)
        }
        let method = target.method.rawValue
        let cacheKey = NetworkCacheType.defaultCacheKey
        var key: String = "\(cacheKey)+\(urlString)+\(method)"
        if let string = parametersString {
            key.append("+\(string)")
        }
        return key.md5()
    }
    
    func cache(_ target: Target, response: Moya.Response, toDisk: Bool = true) {
        switch target.networkCacheType {
        case .cache(let info):
            // config
            self.cache.diskStorage.config = info.diskStorageConfig
            self.cache.memoryStorage.config = info.memoryStorageConfig
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
            let key = self.generateCacheKey(target)
            let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache),.diskCacheExpiration(.days(7)),.memoryCacheExpiration(.seconds(300))])
            self.cache.store(response, forKey: key, options: options, toDisk: toDisk) { result in
                if let diskResultDes = result.diskCacheResult.failure?.errorDescription {
                    // disk Cache Failure
                    print("\(diskResultDes)")
                }
            }
        case .none:
            break
        }
    }
    
    func retrieve(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ result: SYMoyaNetworkResult) -> Void) {
        let key = self.generateCacheKey(target)
        var queue = CallbackQueue.mainAsync
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        self.cache.retrieveResponse(forKey: key, options: options, callbackQueue: queue) { result in
            let resultResponse: SYMoyaNetworkResultResponse
            resultResponse.isDataFromCache = true
            switch result {
            case .success(let networkCacheResult):
                switch networkCacheResult {
                case .memory(let response):
                    resultResponse.response = response
                    completion(.success(resultResponse))
                case .disk(let response):
                    resultResponse.response = response
                    completion(.success(resultResponse))
                case .none:
                    // cache Not Existing
                    completion(.failure(.cacheError(reason: .responseNotExisting(key: key))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func retrieveResponseInMemoryCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo) -> SYMoyaNetworkResult {
        let key = self.generateCacheKey(target)
        if let response = self.cache.retrieveResponseInMemoryCache(forKey: key, options: options) {
            let resultResponse = (response,true)
            return .success(resultResponse)
        }
        return .failure(SYMoyaNetworkError.cacheError(reason: .responseNotExisting(key: key)))
    }
    
    func retrieveResponseInDiskCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completionHandler: @escaping (SYMoyaNetworkResult) -> Void) {
        let key = self.generateCacheKey(target)
        var queue = CallbackQueue.mainAsync
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        self.cache.retrieveResponseInDiskCache(forKey: key, options: options, callbackQueue: queue, completionHandler: completionHandler)
    }
    
    func cacheIfNeeded(_ target: Target, response: Moya.Response) {
        // Cache
        switch target.networkCacheType {
        case .cache(let info):
            switch info.memoryStorageConfig.expiration {
            case .never, .expired:
                switch info.diskStorageConfig.expiration {
                case .expired, .never:
                    break
                default:
                    self.cache(target, response: response)
                }
            default:
                switch info.diskStorageConfig.expiration {
                case .expired, .never:
                    self.cache(target, response: response, toDisk: false)
                default:
                    self.cache(target, response: response)
                }
            }
        case .none:
            break
        }
    }
}

//MARK: - Cache Clean
public extension SYMoyaProvider {
    /// Clears the memory & disk storage of this cache. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    /// This `handler` will be called from the main queue.
    func clearCache(completion handler: (() -> Void)? = nil) {
        self.cache.clearCache(completion: handler)
    }
    
    /// Clears cached data in memory
    func clearMemoryCache() {
        self.cache.clearMemoryCache()
    }
    
    /// Clears cached data from disk
    /// - Parameter handler: Callback method after clear is complete
    func clearDiskCache(completion handler: (() -> Void)? = nil) {
        self.cache.clearDiskCache(completion: handler)
    }
    
    /// Clears expired cached data
    /// - Parameter handler: Callback method after clear is complete
    func cleanExpiredCache(completion handler: (() -> Void)? = nil) {
        self.cache.cleanExpiredCache(completion: handler)
    }

    /// Clears the expired response from disk storage.
    func cleanExpiredMemoryCache() {
        self.cache.cleanExpiredMemoryCache()
    }
    
    /// Clears the expired response from disk storage. This is an async operation.
     func cleanExpiredDiskCache() {
        self.cache.cleanExpiredDiskCache()
    }

    /// Clears expired cached data
    /// - Parameter handler: Callback method after clear is complete
    func cleanExpiredDiskCache(completion handler: (() -> Void)? = nil) {
        self.cache.cleanExpiredDiskCache(completion: handler)
    }
}
