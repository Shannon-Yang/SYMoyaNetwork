//
//  SYMoyaURLCache.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//


import Foundation
import CoreFoundation
import Moya

public let cachedURLResponseUserInfoKey = "com.shannonyang.SYMoyaNetwork.CachedURLResponse.Key"
public let cachedURLResponseUserInfoValue = "com.shannonyang.SYMoyaNetwork.CachedURLResponse.Value"

public class SYMoyaURLCache {
    
    public let urlCache: URLCache
    
    enum RefreshCacheValue:String {
        case refreshCache = "refreshCache"
        case useCache = "useCache"
    }
    
    static let refreshCacheKey = "refreshCache"

    init(urlCache: URLCache) {
        self.urlCache = urlCache
    }
    
}

// MARK: - Private

private extension SYMoyaURLCache {
    
    func addCacheControlHeaderField(headers:NSDictionary,maxAge:Int,isPrivate:Bool) {
        var cacheValue = "max-age=\(maxAge)"
        if isPrivate {
            cacheValue += ",private"
        }
        headers.setValue(cacheValue, forKey: "Cache-Control")
    }
    
    func addExpiresHeaderField(headers:NSDictionary,maxAge:Int) {
        guard let dateString = headers["Date"] as? String else { return }
        let formate = DateFormatter()
        formate.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        formate.timeZone = TimeZone(identifier: "UTC")
        guard let date = formate.date(from: dateString) else { return }
        let expireDate = Date(timeInterval: TimeInterval(maxAge), since: date)
        let cacheValue = formate.string(from: expireDate)
        headers.setValue(cacheValue, forKey: "Expires")
    }
    
}
