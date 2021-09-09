//
//  SYMoyaProvider+URLCache.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/9.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import Alamofire

extension SYMoyaProvider {
    
    func urlCache(_ target: Target, response: Moya.Response, urlCacheInfo: NetworkCacheType.URLCacheInfo) {
        if urlCacheInfo.maxAge <= 0 {
            return
        }
        
        var useServerButRefresh = false
        if let newRequest = response.request {
            if !urlCacheInfo.ignoreServer {
                if newRequest.allHTTPHeaderFields?[SYMoyaURLCache.refreshCacheKey] == SYMoyaURLCache.RefreshCacheValue.refreshCache.rawValue {
                    useServerButRefresh = true
                }
            }
            
            if newRequest.allHTTPHeaderFields?[SYMoyaURLCache.refreshCacheKey] != SYMoyaURLCache.RefreshCacheValue.refreshCache.rawValue {
                let urlCache = self.urlCache.urlCache
                if let value = (urlCache.cachedResponse(for: newRequest)?.response as? HTTPURLResponse)?.allHeaderFields[SYMoyaURLCache.refreshCacheKey] as? String {
                    if value == SYMoyaURLCache.RefreshCacheValue.useCache.rawValue {
                        return
                    }
                }
            }
        }
        
        if response.request?.httpMethod != "GET" {
            debugPrint("Non-GET requests do not support caching!")
            return
        }
        
        
        if response.data.isEmpty {
            return
        }
        
        if let httpResponse = response.response {
            guard let newRequest = response.request else { return }
            guard let newURL = httpResponse.url else { return }
            guard let newHeaders = (httpResponse.allHeaderFields as NSDictionary).mutableCopy() as? NSMutableDictionary else { return }
            let urlCache = self.urlCache.urlCache
            if urlCacheInfo.isCanUseCacheControl {
                if httpResponse.allHeaderFields["Cache-Control"] == nil || (httpResponse.allHeaderFields["Cache-Control"] != nil && ( (httpResponse.allHeaderFields["Cache-Control"] as! String).contains("no-cache")
                                                                                                                                        || (httpResponse.allHeaderFields["Cache-Control"] as! String).contains("no-store"))) || urlCacheInfo.ignoreServer || useServerButRefresh {
                    if urlCacheInfo.ignoreServer {
                        if newHeaders["Vary"] != nil { // http 1.1
                            newHeaders.removeObject(forKey: "Vary")
                        }
                        if newHeaders["Pragma"] != nil {
                            newHeaders.removeObject(forKey: "Pragma")
                        }
                    }
                    self.urlCache.addCacheControlHeaderField(headers: newHeaders, maxAge: urlCacheInfo.maxAge, isPrivate: urlCacheInfo.isPrivate)
                } else {
                    return
                }
            } else {
                if httpResponse.allHeaderFields["Expires"] == nil || urlCacheInfo.ignoreServer || useServerButRefresh {
                    self.urlCache.addExpiresHeaderField(headers: newHeaders, maxAge: urlCacheInfo.maxAge)
                    if urlCacheInfo.ignoreServer {
                        if httpResponse.allHeaderFields["Pragma"] != nil {
                            newHeaders["Pragma"] = "cache"
                        }
                        if newHeaders["Cache-Control"] != nil {
                            newHeaders.removeObject(forKey: "Cache-Control")
                        }
                    }
                } else {
                    return
                }
            }
            newHeaders[SYMoyaURLCache.refreshCacheKey] = SYMoyaURLCache.RefreshCacheValue.useCache.rawValue
            if let newResponse = HTTPURLResponse(url: newURL, statusCode: httpResponse.statusCode, httpVersion: urlCacheInfo.HTTPVersion, headerFields: newHeaders as? [String : String]) {
                
                let newCacheResponse = CachedURLResponse(response: newResponse, data: response.data, userInfo: [cachedURLResponseUserInfoKey: cachedURLResponseUserInfoValue], storagePolicy: URLCache.StoragePolicy.allowed)
                
                urlCache.storeCachedResponse(newCacheResponse, for: newRequest)
            }
        }
    }
}

extension SYMoyaProvider {
    
    public func clearURLCache(_ request: URLRequest, urlCacheInfo: NetworkCacheType.URLCacheInfo) {
        let urlCache = self.urlCache.urlCache
        if let cachedResponse = urlCache.cachedResponse(for: request) {
            if let httpResponse = cachedResponse.response as? HTTPURLResponse {
                let newData = cachedResponse.data
                guard let newURL = httpResponse.url else { return }
                guard let newHeaders = (httpResponse.allHeaderFields as NSDictionary).mutableCopy() as? NSMutableDictionary else { return }
                if urlCacheInfo.isCanUseCacheControl {
                    self.urlCache.addCacheControlHeaderField(headers: newHeaders, maxAge: 0, isPrivate: false)
                } else {
                    self.urlCache.addExpiresHeaderField(headers: newHeaders, maxAge: 0)
                }
                if let newResponse = HTTPURLResponse(url: newURL, statusCode: httpResponse.statusCode, httpVersion: urlCacheInfo.HTTPVersion, headerFields: newHeaders as? [String : String]) {
                    
                    let newCacheResponse = CachedURLResponse(response: newResponse, data: newData, userInfo: [cachedURLResponseUserInfoKey: cachedURLResponseUserInfoValue], storagePolicy: URLCache.StoragePolicy.allowed)
                    urlCache.storeCachedResponse(newCacheResponse, for: request)
                }
            }
        }
    }


    public func clearCache(_ target: Target, urlCacheInfo: NetworkCacheType.URLCacheInfo) {
        let httpHeaders = target.headers == nil ? nil : HTTPHeaders(target.headers!)
        if var urlRequest = try? URLRequest(url: URL(target: target), method: Moya.Method.get, headers: httpHeaders) {
            urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
            switch target.task {
            case .requestParameters(let parameters, let encoding):
                if let newRequest = try? encoding.encode(urlRequest, with: parameters) {
                    self.clearURLCache(newRequest, urlCacheInfo: urlCacheInfo)
                }
            case .requestCompositeParameters(_, let bodyEncoding, let urlParameters):
                if let newRequest = try? bodyEncoding.encode(urlRequest, with: urlParameters) {
                    self.clearURLCache(newRequest, urlCacheInfo: urlCacheInfo)
                }
            case .downloadParameters(let parameters, let encoding, _):
                if let newRequest = try? encoding.encode(urlRequest, with: parameters) {
                    self.clearURLCache(newRequest, urlCacheInfo: urlCacheInfo)
                }
            default:
                break
            }
        }
    }
    
}


