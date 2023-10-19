//
//  SYMoyaProvider+SwiftyJSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/25.
//

import Foundation
import Moya
import SwiftyJSON
import Combine

//MARK: - SwiftyJSON Provider Combine
public extension SYMoyaProvider {
    
    /// Get SwiftyJSON data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseSwiftyJSONFromCachePublisher(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            self.responseSwiftyJSONFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseSwiftyJSONFromDiskCachePublisher(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            self.responseSwiftyJSONFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseSwiftyJSONFromMemoryCachePublisher(_ target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            let json = self.responseSwiftyJSONFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(json)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseSwiftyJSONPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return SYMoyaPublisher { subscriber in
            return self.responseSwiftyJSON(responseDataSourceType,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
