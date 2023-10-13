//
//  SYMoyaProvider+JSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import SwiftyJSON
import Combine

//MARK: - JSON Provider Combine
public extension SYMoyaProvider {
    
    func responseJSONFromCachePublisher(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            self.responseJSONFromCache(target, serializer: serializer, callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseJSONFromCacheDiskCachePublisher(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            self.responseJSONFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseJSONFromMemoryCachePublisher(_ target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse = self.responseJSONFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseJSONPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            return self.responseJSON(responseDataSourceType, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
        }
    }
}
