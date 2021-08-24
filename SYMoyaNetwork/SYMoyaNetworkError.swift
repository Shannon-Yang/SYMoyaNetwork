//
//  SYMoyaNetworkError.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/24.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation

/// Represents all the errors which can happen in Kingfisher framework.
/// Kingfisher related methods always throw a `KingfisherError` or invoke the callback with `KingfisherError`
/// as its error type. To handle errors from Kingfisher, you switch over the error to get a reason catalog,
/// then switch over the reason to know error detail.
public enum SYMoyaNetworkError: Error {

    // MARK: Error Reason Types
    
    /// Represents the error reason during Kingfisher caching system.
    ///
    /// - fileEnumeratorCreationFailed: Cannot create a file enumerator for a certain disk URL. Code 3001.
    /// - invalidFileEnumeratorContent: Cannot get correct file contents from a file enumerator. Code 3002.
    /// - invalidURLResource: The file at target URL exists, but its URL resource is unavailable. Code 3003.
    /// - cannotLoadDataFromDisk: The file at target URL exists, but the data cannot be loaded from it. Code 3004.
    /// - cannotCreateDirectory: Cannot create a folder at a given path. Code 3005.
    /// - imageNotExisting: The requested image does not exist in cache. Code 3006.
    /// - cannotConvertToData: Cannot convert an object to data for storing. Code 3007.
    /// - cannotSerializeImage: Cannot serialize an image to data for storing. Code 3008.
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
        
        /// The requested image does not exist in cache. Code 3006.
        /// - key: Key of the requested image in cache.
        case imageNotExisting(key: String)
        
        /// Cannot convert an object to data for storing. Code 3007.
        /// - object: The object which needs be convert to data.
        case cannotConvertToData(object: Any, error: Error)
        
        /// Cannot serialize an image to data for storing. Code 3008.
        /// - image: The input image needs to be serialized to cache.
        /// - original: The original image data, if exists.
        /// - serializer: The `CacheSerializer` used for the image serializing.
//        case cannotSerializeImage(image: KFCrossPlatformImage?, original: Data?, serializer: CacheSerializer)

        /// Cannot create the cache file at a certain fileURL under a key. Code 3009.
        /// - fileURL: The url where the cache file should be created.
        /// - key: The cache key used for the cache. When caching a file through `KingfisherManager` and Kingfisher's
        ///        extension method, it is the resolved cache key based on your input `Source` and the image processors.
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
        /// Kingfisher failed even when creating the cache folder. The disk storage will be in unusable state. Normally,
        /// ask user to free some spaces and restart the app to make the disk storage work again.
        /// - cacheURL: The intended URL which should be the storage folder.
        case diskStorageIsNotReady(cacheURL: URL)
    }
    
    // MARK: Member Cases
    
    /// Represents the error reason during networking request phase.
//    case requestError(reason: RequestErrorReason)
//    /// Represents the error reason during networking response phase.
//    case responseError(reason: ResponseErrorReason)
    /// Represents the error reason during Kingfisher caching system.
    case cacheError(reason: CacheErrorReason)
    /// Represents the error reason during image processing phase.
//    case processorError(reason: ProcessorErrorReason)
//    /// Represents the error reason during image setting in a view related class.
//    case imageSettingError(reason: ImageSettingErrorReason)
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

    /// The error domain of `SYMoyaNetworkError`. All errors from Kingfisher is under this domain.
    public static let domain = "com.shannonyang.SYMoyaNetwork.Error"

    /// The error code within the given domain.
    public var errorCode: Int {
        switch self {
//        case .requestError(let reason): return reason.errorCode
//        case .responseError(let reason): return reason.errorCode
        case .cacheError(let reason): return reason.errorCode
//        case .processorError(let reason): return reason.errorCode
//        case .imageSettingError(let reason): return reason.errorCode
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
        case .imageNotExisting(let key):
            return "The image is not in cache, but you requires it should only be " +
                   "from cache by enabling the `.onlyFromCache` option. Key: \(key)."
        case .cannotConvertToData(let object, let error):
            return "Cannot convert the input object to a `Data` object when storing it to disk cache. " +
                   "Object: \(object). Underlying error: \(error)"
//        case .cannotSerializeImage(let image, let originalData, let serializer):
//            return "Cannot serialize an image due to the cache serializer returning `nil`. " +
//                   "Image: \(String(describing:image)), original data: \(String(describing: originalData)), " +
//                   "serializer: \(serializer)."
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
        case .imageNotExisting: return 30006
        case .cannotConvertToData: return 30007
//        case .cannotSerializeImage: return 3008
        case .cannotCreateCacheFile: return 30009
        case .cannotSetCacheFileAttribute: return 30010
        case .diskStorageIsNotReady: return 30011
        }
    }
}
