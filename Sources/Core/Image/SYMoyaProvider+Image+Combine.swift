//
//  SYMoyaProvider+Image+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

#if canImport(Combine)
import Foundation
import Moya
import Combine

//MARK: - Image Provider Combine
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SYMoyaProvider {
    
    func responseImageFromCachePublisher(_ target: Target, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            self.responseImageFromCache(target,callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseImageFromDiskCachePublisher(_ target: Target, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            self.responseImageFromDiskCache(target, callbackQueue: callbackQueue,completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseImageFromMemoryCachePublisher(_ target: Target) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse = self.responseImageFromMemoryCache(target)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseImagePublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseImage(responseDataSourceType,target: target, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
        }
    }
}
#endif

