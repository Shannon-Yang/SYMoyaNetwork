//
//  NetworkCacheTest.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/15.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import XCTest
import Moya
@testable import SYMoyaNetwork

func clearCaches(_ caches: [NetworkCache]) {
    for c in caches {
        c.clearMemoryCache()
        try? c.diskStorage.removeAll(skipCreatingDirectory: true)
    }
}

let testKeys = [
    "Key1",
    "Key2",
    "Key3",
    "Key4"
]

func cleanDefaultCache() {
    let cache = NetworkConfig.sharedInstance.networkCache
    cache.clearMemoryCache()
    try? cache.diskStorage.removeAll()
}

class NetworkCacheTest: XCTestCase {
    
    var cache: NetworkCache!
    var response: Moya.Response!
    var observer: NSObjectProtocol!

    override func setUp() {
        super.setUp()
        
        let uuid = UUID().uuidString
        let cacheName = "test-\(uuid)"
        cache = NetworkCache(name: cacheName)
        
        
        let fileURL = Bundle(for: Self.self).url(forResource: "test", withExtension: "json")!
        let data = try! Data(contentsOf: fileURL)
        
        response = Moya.Response(statusCode: 200, data: data)
    }
    
    override func tearDown() {
        clearCaches([cache])
        cache = nil
        observer = nil
        
        super.tearDown()
    }
    
    func testInvalidCustomCachePath() {
        let customPath = "/path/to/Network/cache"
        let url = URL(fileURLWithPath: customPath)
        XCTAssertThrowsError(try NetworkCache(name: "test", cacheDirectoryURL: url)) { error in
            guard case SYMoyaNetworkError.cacheError(reason: .cannotCreateDirectory(let path, _)) = error else {
                XCTFail("Should be SYMoyaNetworkError with cacheError reason.")
                return
            }
            XCTAssertEqual(path, customPath + "/com.shannonyang.SYMoyaNetwork.NetworkCache.test")
        }
    }
    
    func testCustomCachePath() {
        let cacheURL = try! FileManager.default.url(
            for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let subFolder = cacheURL.appendingPathComponent("temp")
        
        let customPath = subFolder.path
        let cache = try! NetworkCache(name: "test", cacheDirectoryURL: subFolder)
        XCTAssertEqual(
            cache.diskStorage.directoryURL.path,
            (customPath as NSString).appendingPathComponent("com.shannonyang.SYMoyaNetwork.NetworkCache.test"))
        clearCaches([cache])
    }
    
    func testCustomCachePathByBlock() {
        let cache = try! NetworkCache(name: "test", cacheDirectoryURL: nil, diskCachePathClosure: { (url, path) -> URL in
            let modifiedPath = path + "-modified"
            return url.appendingPathComponent(modifiedPath, isDirectory: true)
        })
        let cacheURL = try! FileManager.default.url(
            for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        XCTAssertEqual(
            cache.diskStorage.directoryURL.path,
            (cacheURL.path as NSString).appendingPathComponent("com.shannonyang.SYMoyaNetwork.NetworkCache.test-modified"))
        clearCaches([cache])
    }
    
    func testMaxCachePeriodInSecond() {
        cache.diskStorage.config.expiration = .seconds(1)
        XCTAssertEqual(cache.diskStorage.config.expiration.timeInterval, 1)
    }
    
    func testMaxMemorySize() {
        cache.memoryStorage.config.totalCostLimit = 1
        XCTAssert(cache.memoryStorage.config.totalCostLimit == 1, "maxMemoryCost should be able to be set.")
    }
    
    func testMaxDiskCacheSize() {
        cache.diskStorage.config.sizeLimit = 1
        XCTAssert(cache.diskStorage.config.sizeLimit == 1, "maxDiskCacheSize should be able to be set.")
    }
    
    func testClearDiskCache() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        cache.store(response, forKey: key, toDisk: true) { _ in
            self.cache.clearMemoryCache()
            let cacheResult = self.cache.responseCachedType(forKey: key)
            XCTAssertTrue(cacheResult.cached)
            XCTAssertEqual(cacheResult, .disk)
            
            self.cache.clearDiskCache {
                let cacheResult = self.cache.responseCachedType(forKey: key)
                XCTAssertFalse(cacheResult.cached)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 3, handler:nil)
    }
    
    func testClearMemoryCache() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        cache.store(response, forKey: key, toDisk: true) { _ in
            self.cache.clearMemoryCache()
            self.cache.retrieveResponse(forKey: key) { result in
                XCTAssertNotNil(result.success?.response)
                XCTAssertEqual(result.success?.cacheType, .disk)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testNoResponseFound() {
        let exp = expectation(description: #function)
        cache.retrieveResponse(forKey: "test") { result in
            XCTAssertNil(result.success?.response)
            exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCachedFileDoesNotExist() {
        let exists = cache.responseCachedType(forKey: "default").cached
        XCTAssertFalse(exists)
    }
    
    func testStoreResponseInMemory() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        cache.store(response, forKey: key, toDisk: false) { _ in
            self.cache.retrieveResponse(forKey: key) { result in
                XCTAssertNotNil(result.success?.response)
                XCTAssertEqual(result.success?.cacheType, .memory)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testStoreMultipleImages() {
        let exp = expectation(description: #function)
        storeMultipleResponses {
            let diskCachePath = self.cache.diskStorage.directoryURL.path
            var files: [String] = []
            do {
                files = try FileManager.default.contentsOfDirectory(atPath: diskCachePath)
            } catch _ {
                XCTFail()
            }
            XCTAssertEqual(files.count, testKeys.count)
            exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCachedFileExists() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        
        let exists = cache.responseCachedType(forKey: key).cached
        XCTAssertFalse(exists)
    
        cache.retrieveResponse(forKey: key) { result in
            let options = XCTExpectedFailure.Options()
            // Set its strictness: Test succeeds, even if an expected failure doesn't occur.
            options.isStrict = false
            XCTExpectFailure(result.failure.debugDescription,options: options)
            self.cache.store(self.response, forKey: key, toDisk: true) { _ in
                self.cache.retrieveResponse(forKey: key) { result in
                    XCTAssertNotNil(result.success?.response)
                    XCTAssertEqual(result.success?.cacheType, .memory)
                    
                    self.cache.clearMemoryCache()
                    self.cache.retrieveResponse(forKey: key) { result in
                        XCTAssertNotNil(result.success?.response)
                        XCTAssertEqual(result.success?.cacheType, .disk)
                        
                        exp.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    
    func testCachedImageIsFetchedSyncronouslyFromTheMemoryCache() {
        cache.store(response, forKey: testKeys[0], toDisk: false)
        var foundResponse: Moya.Response?
        cache.retrieveResponse(forKey: testKeys[0]) { result in
            foundResponse = result.success?.response
        }
        XCTAssertEqual(response, foundResponse)
    }
    
    func testIsImageCachedForKey() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        XCTAssertFalse(cache.responseCachedType(forKey: key).cached)
        cache.store(response, forKey: key, toDisk: true) { _ in
            XCTAssertTrue(self.cache.responseCachedType(forKey: key).cached)
            exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCleanDiskCacheNotification() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        
        cache.diskStorage.config.expiration = .seconds(0.01)
        
        cache.store(response, forKey: key, toDisk: true) { _ in
            self.observer = NotificationCenter.default.addObserver(
                forName: .SYMoyaNetworkDidCleanDiskCache,
                object: self.cache,
                queue: .main) {
                    noti in
                    let receivedCache = noti.object as? NetworkCache
                    XCTAssertNotNil(receivedCache)
                    XCTAssertTrue(receivedCache === self.cache)
                    
                    guard let hashes = noti.userInfo?[SYMoyaNetworkDiskCacheCleanedHashKey] as? [String] else {
                        XCTFail("Notification should contains Strings in key 'SYMoyaNetworkDiskCacheCleanedHashKey'")
                        exp.fulfill()
                        return
                    }
                    
                    XCTAssertEqual(hashes.count, 1)
                    XCTAssertEqual(hashes.first!, self.cache.hash(forKey: key))
                    guard let o = self.observer else { return }
                    NotificationCenter.default.removeObserver(o)
                    exp.fulfill()
                }
            
            delay(1) {
                self.cache.cleanExpiredDiskCache()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDefaultCache() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        let cache = NetworkConfig.sharedInstance.networkCache
        cache.store(response, forKey: key) { _ in
            XCTAssertTrue(cache.memoryStorage.isCached(forKey: key))
            XCTAssertTrue(cache.diskStorage.isCached(forKey: key))
            cleanDefaultCache()
            exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRetrieveDiskCacheSynchronously() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        cache.store(response, forKey: key, toDisk: true) { _ in
            var cacheType = self.cache.responseCachedType(forKey: key)
            XCTAssertEqual(cacheType, .memory)
            
            self.cache.memoryStorage.remove(forKey: key)
            cacheType = self.cache.responseCachedType(forKey: key)
            XCTAssertEqual(cacheType, .disk)
            
            var dispatched = false
            self.cache.retrieveResponseInDiskCache(forKey: key, options:  [.loadDiskFileSynchronously]) {
                result in
                XCTAssertFalse(dispatched)
                exp.fulfill()
            }
            // This should be called after the completion handler above.
            dispatched = true
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRetrieveDiskCacheAsynchronously() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        cache.store(response, forKey: key, toDisk: true) { _ in
            var cacheType = self.cache.responseCachedType(forKey: key)
            XCTAssertEqual(cacheType, .memory)
            
            self.cache.memoryStorage.remove(forKey: key)
            cacheType = self.cache.responseCachedType(forKey: key)
            XCTAssertEqual(cacheType, .disk)
            
            var dispatched = false
            self.cache.retrieveResponseInDiskCache(forKey: key, options:  nil) {
                result in
                XCTAssertTrue(dispatched)
                exp.fulfill()
            }
            // This should be called before the completion handler above.
            dispatched = true
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testStoreToMemoryWithExpiration() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        cache.store(
            response,
            forKey: key,
            options: SYMoyaNetworkParsedOptionsInfo([.memoryCacheExpiration(.seconds(0.2))]),
            toDisk: true)
        {
            _ in
            XCTAssertEqual(self.cache.responseCachedType(forKey: key), .memory)
            delay(1) {
                XCTAssertEqual(self.cache.responseCachedType(forKey: key), .disk)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testStoreToDiskWithExpiration() {
        let exp = expectation(description: #function)
        let key = testKeys[0]
        cache.store(
            response,
            forKey: key,
            options: SYMoyaNetworkParsedOptionsInfo([.diskCacheExpiration(.expired)]),
            toDisk: true)
        {
            _ in
            XCTAssertEqual(self.cache.responseCachedType(forKey: key), .memory)
            self.cache.clearMemoryCache()
            XCTAssertEqual(self.cache.responseCachedType(forKey: key), .none)
            exp.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCalculateDiskStorageSize() {
        let exp = expectation(description: #function)
        cache.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                XCTAssertEqual(size, 0)
                self.storeMultipleResponses {
                    self.cache.calculateDiskStorageSize { result in
                        switch result {
                        case .success(let size):
                            XCTAssertEqual(size, UInt(self.response.data.count * testKeys.count))
                        case .failure:
                            XCTAssert(false)
                        }
                        exp.fulfill()
                    }
                }
            case .failure:
                XCTAssert(false)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
#if swift(>=5.5)
#if canImport(_Concurrency)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testCalculateDiskStorageSizeAsync() async throws {
        let size = try await cache.diskStorageSize
        XCTAssertEqual(size, 0)
        _ = await storeMultipleImagesAsync()
        let sizeAfterStoreMultipleImages = try await cache.diskStorageSize
        XCTAssertEqual(sizeAfterStoreMultipleImages, UInt(response.data.count * testKeys.count))
    }
#endif
#endif
    
    // MARK: - Helper
    private func storeMultipleResponses(_ completionHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        testKeys.forEach {
            group.enter()
            cache.store(response, forKey: $0, toDisk: true) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main, execute: completionHandler)
    }
    
#if swift(>=5.5)
#if canImport(_Concurrency)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    private func storeMultipleImagesAsync() async {
        await withCheckedContinuation { continuation in
            storeMultipleResponses {
                continuation.resume()
            }
        }
    }
#endif
#endif
}
