//
//  SYMoyaProvider+JSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

#if canImport(Combine)
import Foundation
import Moya
import SwiftyJSON
import Combine

//MARK: - SwiftyJSON Provider Combine
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SYMoyaProvider {
    
    func responseJSONFromCachePublisher(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            self.responseJSONFromCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseJSONFromCacheDiskCachePublisher(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            self.responseJSONFromDiskCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseJSONFromMemoryCachePublisher(_ target: Target,failsOnEmptyData: Bool = true) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse = self.responseJSONFromMemoryCache(target, failsOnEmptyData: failsOnEmptyData)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseJSONPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Any>> {
        return SYMoyaPublisher { subscriber in
            return self.responseJSON(responseDataSourceType, target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
        }
    }
}
#endif
