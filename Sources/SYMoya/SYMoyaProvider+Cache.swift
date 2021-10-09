//
//  SYMoyaProvider+Cache.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/15.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - Cache

extension SYMoyaProvider {
    
    func generateCacheKey(_ target: Target) -> String {
        let urlString = URL(target: target).absoluteString
        
        var parametersString: String?
        if let httpBody = try? self.endpoint(target).urlRequest().httpBody {
            parametersString = String(decoding: httpBody, as: UTF8.self)
        }
        
        let method = target.method.rawValue
        
        var cacheKey: String = NetworkCacheType.defaultCacheKey
        switch target.networkCacheType {
        case .syMoyaNetworkCache(let info):
            cacheKey = info.cacheKey
        default:
            break
        }
        
        var key: String = "\(cacheKey)+\(urlString)+\(method)"
        if let string = parametersString {
            key.append("+\(string)")
        }
        return key.md5()
    }
    
    
    func cache(_ target: Target, response: Moya.Response, toDisk: Bool = true) {
        switch target.networkCacheType {
        case .syMoyaNetworkCache(let networkCacheOptionsInfo):
            // config
            self.cache.diskStorage.config = networkCacheOptionsInfo.diskStorageConfig
            self.cache.memoryStorage.config = networkCacheOptionsInfo.memoryStorageConfig
            
            if networkCacheOptionsInfo.diskStorageConfig.expiration.isExpired {
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
        case .urlRequestCache(let urlCacheInfo):
            self.urlCache(target, response: response, urlCacheInfo: urlCacheInfo)
        case .none:
            break
        }
    }
    
    func retrieve(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ result: Result<Moya.Response, SYMoyaNetworkError>) -> Void) {
        let key = self.generateCacheKey(target)
        var queue = CallbackQueue.untouch
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        self.cache.retrieveResponse(forKey: key, options: options, callbackQueue: queue) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let networkCacheResult):
                    switch networkCacheResult {
                    case .memory(let response):
                        completion(.success(response))
                    case .disk(let response):
                        completion(.success(response))
                    case .none:
                        // cache Not Existing
                        completion(.failure(.cacheError(reason: .responseNotExisting(key: key))))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func retrieveResponseInMemoryCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo) throws -> Moya.Response {
        let key = self.generateCacheKey(target)
        if let data = self.cache.retrieveResponseInMemoryCache(forKey: key, options: options) {
            return data
        }
        throw SYMoyaNetworkError.cacheError(reason: .responseNotExisting(key: key))
    }
    
    func retrieveResponseInDiskCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completionHandler: @escaping (Result<Moya.Response, SYMoyaNetworkError>) -> Void) {
        let key = self.generateCacheKey(target)
        var queue = CallbackQueue.untouch
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        self.cache.retrieveResponseInDiskCache(forKey: key, options: options, callbackQueue: queue, completionHandler: completionHandler)
    }
    
    func cacheIfNeeded(_ target: Target, response: Moya.Response) {
        // Cache
        switch target.networkCacheType {
        case .urlRequestCache:
            break
        case .syMoyaNetworkCache(let info):
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
    ///                      This `handler` will be called from the main queue.
    
    func clearCache(completion handler: (() -> Void)? = nil) {
        self.cache.clearCache(completion: handler)
    }
    
    func clearMemoryCache() {
        self.cache.clearMemoryCache()
    }
    
    func clearDiskCache(completion handler: (() -> Void)? = nil) {
        self.cache.clearDiskCache(completion: handler)
    }
    
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

    func cleanExpiredDiskCache(completion handler: (() -> Void)? = nil) {
        self.cache.cleanExpiredDiskCache(completion: handler)
    }
    
}
