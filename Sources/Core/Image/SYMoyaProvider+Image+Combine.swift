//
//  SYMoyaProvider+Image+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import Combine

//MARK: - Image Provider Combine
public extension SYMoyaProvider {
    
    func responseImageFromCachePublisher(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            self.responseImageFromCache(target,serializer: serializer,callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseImageFromDiskCachePublisher(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            self.responseImageFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue,completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseImageFromMemoryCachePublisher(_ target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse = self.responseImageFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseImagePublisher(_ type: ResponseDataSourceType = .server, target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<Image>> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseImage(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
        }
    }
}

