//
//  SYMoyaNetworkError.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/24.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Represents all the errors which can happen in SYMoyaNetwork framework.
/// SYMoyaNetwork related methods always throw a `SYMoyaNetworkError` or invoke the callback with `SYMoyaNetworkError`
/// as its error type. To handle errors from SYMoyaNetwork, you switch over the error to get a reason catalog,
/// then switch over the reason to know error detail.
public enum SYMoyaNetworkError: Swift.Error {

    // MARK: Error Reason Types
    
    /// Represents the error reason during SYMoyaNetwork caching system.
    ///
    /// - fileEnumeratorCreationFailed: Cannot create a file enumerator for a certain disk URL. Code 3001.
    /// - invalidFileEnumeratorContent: Cannot get correct file contents from a file enumerator. Code 3002.
    /// - invalidURLResource: The file at target URL exists, but its URL resource is unavailable. Code 3003.
    /// - cannotLoadDataFromDisk: The file at target URL exists, but the data cannot be loaded from it. Code 3004.
    /// - cannotCreateDirectory: Cannot create a folder at a given path. Code 3005.
    /// - responseNotExisting: The requested response does not exist in cache. Code 3006.
    /// - cannotConvertToData: Cannot convert an object to data for storing. Code 3007.
    /// - cannotSerializeResponse: Cannot serialize an response to data for storing. Code 3008.
    /// - cannotCreateCacheFile: Cannot create the cache file at a certain fileURL under a key. Code 3009.
    /// - cannotSetCacheFileAttribute: Cannot set file attributes to a cached file. Code 3010.
    public enum CacheErrorReason {
        
        /// Cannot create a file enumerator for a certain disk URL. Code 3001.
        /// - url: The target disk URL from which the file enumerator should be created.
        case fileEnumeratorCreationFailed(url: URL)
        
        /// Cannot get correct file contents from a file enumerator. Code 3002.
        /// - url: The target disk URL from which the content of a file enumerator should be got.
        case invalidFileEnumeratorContent(url: URL)
        
        /// The file at target URL exists, but its URL resource is unavailable. Code 3003.
        /// - error: The underlying error thrown by file manager.
        /// - key: The key used to getting the resource from cache.
        /// - url: The disk URL where the target cached file exists.
        case invalidURLResource(error: Error, key: String, url: URL)
        
        /// The file at target URL exists, but the data cannot be loaded from it. Code 3004.
        /// - url: The disk URL where the target cached file exists.
        /// - error: The underlying error which describes why this error happens.
        case cannotLoadDataFromDisk(url: URL, error: Error)
        
        /// Cannot create a folder at a given path. Code 3005.
        /// - path: The disk path where the directory creating operation fails.
        /// - error: The underlying error which describes why this error happens.
        case cannotCreateDirectory(path: String, error: Error)
        
        /// The requested response does not exist in cache. Code 3006.
        /// - key: Key of the requested response in cache.
        case responseNotExisting(key: String)
        
        /// Cannot convert an object to data for storing. Code 3007.
        /// - object: The object which needs be convert to data.
        case cannotConvertToData(object: Any, error: Error)
        
        /// Cannot serialize an response to data for storing. Code 3008.
        /// - response: The input response needs to be serialized to cache.
        /// - original: The original response data, if exists.
        /// - serializer: The `CacheSerializer` used for the response serializing.
        case cannotSerializeResponse(response: Moya.Response?, serializer: CacheSerializer)

        /// Cannot create the cache file at a certain fileURL under a key. Code 3009.
        /// - fileURL: The url where the cache file should be created.
        /// - key: The cache key used for the cache. When caching a file through `SYMoyaNetworkManager` and SYMoyaNetwork's
        ///        extension method, it is the resolved cache key based on your input `Source` and the response processors.
        /// - data: The data to be cached.
        /// - error: The underlying error originally thrown by Foundation when writing the `data` to the disk file at
        ///          `fileURL`.
        case cannotCreateCacheFile(fileURL: URL, key: String, data: Data, error: Error)

        /// Cannot set file attributes to a cached file. Code 3010.
        /// - filePath: The path of target cache file.
        /// - attributes: The file attribute to be set to the target file.
        /// - error: The underlying error originally thrown by Foundation when setting the `attributes` to the disk
        ///          file at `filePath`.
        case cannotSetCacheFileAttribute(filePath: String, attributes: [FileAttributeKey : Any], error: Error)

        /// The disk storage of cache is not ready. Code 3011.
        ///
        /// This is usually due to extremely lack of space on disk storage, and
        /// SYMoyaNetwork failed even when creating the cache folder. The disk storage will be in unusable state. Normally,
        /// ask user to free some spaces and restart the app to make the disk storage work again.
        /// - cacheURL: The intended URL which should be the storage folder.
        case diskStorageIsNotReady(cacheURL: URL)
    }
    
    // MARK: Member Cases
    
    /// Represents the error reason during networking request phase.
//    case requestError(reason: RequestErrorReason)
//    /// Represents the error reason during networking response phase.
//    case responseError(reason: ResponseErrorReason)
    /// Represents the error reason during SYMoyaNetwork caching system.
    case cacheError(reason: CacheErrorReason)
    /// Represents the error reason during response processing phase.
//    case processorError(reason: ProcessorErrorReason)
//    /// Represents the error reason during response setting in a view related class.
//    case responseSettingError(reason: ResponseSettingErrorReason)
}


// MARK: - LocalizedError Conforming
extension SYMoyaNetworkError: LocalizedError {
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
//        case .requestError(let reason): return reason.errorDescription
//        case .responseError(let reason): return reason.errorDescription
        case .cacheError(let reason): return reason.errorDescription
//        case .processorError(let reason): return reason.errorDescription
        }
    }
}


// MARK: - CustomNSError Conforming
extension SYMoyaNetworkError: CustomNSError {

    /// The error domain of `SYMoyaNetworkError`. All errors from SYMoyaNetwork is under this domain.
    public static let domain = "com.shannonyang.SYMoyaNetwork.Error"

    /// The error code within the given domain.
    public var errorCode: Int {
        switch self {
//        case .requestError(let reason): return reason.errorCode
//        case .responseError(let reason): return reason.errorCode
        case .cacheError(let reason): return reason.errorCode
//        case .processorError(let reason): return reason.errorCode
//        case .responseSettingError(let reason): return reason.errorCode
        }
    }
}

extension SYMoyaNetworkError.CacheErrorReason {
    var errorDescription: String? {
        switch self {
        case .fileEnumeratorCreationFailed(let url):
            return "Cannot create file enumerator for URL: \(url)."
        case .invalidFileEnumeratorContent(let url):
            return "Cannot get contents from the file enumerator at URL: \(url)."
        case .invalidURLResource(let error, let key, let url):
            return "Cannot get URL resource values or data for the given URL: \(url). " +
                   "Cache key: \(key). Underlying error: \(error)"
        case .cannotLoadDataFromDisk(let url, let error):
            return "Cannot load data from disk at URL: \(url). Underlying error: \(error)"
        case .cannotCreateDirectory(let path, let error):
            return "Cannot create directory at given path: Path: \(path). Underlying error: \(error)"
        case .responseNotExisting(let key):
            return "The response is not in cache, but you requires it should only be " +
                   "from cache by enabling the `.onlyFromCache` option. Key: \(key)."
        case .cannotConvertToData(let object, let error):
            return "Cannot convert the input object to a `Data` object when storing it to disk cache. " +
                   "Object: \(object). Underlying error: \(error)"
        case .cannotSerializeResponse(let response, let serializer):
//            return "Cannot serialize an response due to the cache serializer returning `nil`. " +
//                   "Response: \(String(describing:response)), original data: \(String(describing: originalData)), " +
//                   "serializer: \(serializer)."
        return ""
        case .cannotCreateCacheFile(let fileURL, let key, let data, let error):
            return "Cannot create cache file at url: \(fileURL), key: \(key), data length: \(data.count). " +
                   "Underlying foundation error: \(error)."
        case .cannotSetCacheFileAttribute(let filePath, let attributes, let error):
            return "Cannot set file attribute for the cache file at path: \(filePath), attributes: \(attributes)." +
                   "Underlying foundation error: \(error)."
        case .diskStorageIsNotReady(let cacheURL):
            return "The disk storage is not ready to use yet at URL: '\(cacheURL)'. " +
                "This is usually caused by extremely lack of disk space. Ask users to free up some space and restart the app."
        }
    }
    
    var errorCode: Int {
        switch self {
        case .fileEnumeratorCreationFailed: return 30001
        case .invalidFileEnumeratorContent: return 30002
        case .invalidURLResource: return 30003
        case .cannotLoadDataFromDisk: return 30004
        case .cannotCreateDirectory: return 30005
        case .responseNotExisting: return 30006
        case .cannotConvertToData: return 30007
        case .cannotSerializeResponse: return 30008
        case .cannotCreateCacheFile: return 30009
        case .cannotSetCacheFileAttribute: return 30010
        case .diskStorageIsNotReady: return 30011
        }
    }
}
