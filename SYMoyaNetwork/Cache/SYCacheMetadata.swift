//
//  SYCacheMetadata.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/27.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import ObjectMapper

/// store cached metadata, implement NSSecureCoding protocol

class SYCacheMetadata: NSObject, NSSecureCoding {
    
    public enum ProviderSerializerType {
        case image
        case string(keyPath: String?)
        case json(failsOnEmptyData: Bool = true)
        case codable(keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true)
        case swiftyjson(opt: JSONSerialization.ReadingOptions = [])
        case objectmapper(keyPath: String? = nil, context: MapContext? = nil)
    }
    
    /// can be used to identify and invalidate local cache
    
    let cacheKey: String
    
    /// cachemetadate create data
    
    let createDate: Date
    
    let serializerType: ProviderSerializerType
    
    let lastUpdate: Data
    
    let estimatedExpirationDate: Data
    
    /// supportsSecureCoding
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    //MARK: - Enum
    
    enum Key: String {
        case cacheKey
        case creationDate
        case responseStringEncoding
        case responseJSONOptions
        case responsePropertyListOptions
        case responseObjectKeyPath
        case responseObjectContext
    }
    
    
    //MARK: - aDecoder
    
    required init?(coder aDecoder: NSCoder) {
        self.cacheKey = aDecoder.decodeObject(forKey: Key.cacheKey.rawValue) as! String
        self.createDate = aDecoder.decodeObject(forKey: Key.createDate.rawValue) as! Date
       
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.cacheKey, forKey: Key.cacheKey.rawValue)
        aCoder.encode(self.createDate, forKey: Key.createDate.rawValue)

    }
    
    //MARK: - Init
    
    override init() {
        self.cacheKey = NetworkCacheType.defaultCacheKey
        self.createDate = Date()
        self.responsePropertyListOptions = []
        self.responseStringEncoding = .isoLatin1
        self.responseJSONOptions = .allowFragments
        super.init()
    }
    
}


