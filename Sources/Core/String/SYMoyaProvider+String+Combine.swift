//
//  SYMoyaProvider+String+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import Combine

//MARK: - SwiftyJSON Provider Combine
public extension SYMoyaProvider {
    func responseStringFromCachePublisher(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            self.responseStringFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { response in
                _ = subscriber.receive(response)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseStringFromDiskCachePublisher(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            self.responseStringFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { response in
                _ = subscriber.receive(response)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseStringFromMemoryCachePublisher(_ target: Target, serializer: StringResponseSerializer = .defaultStringSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            let response = self.responseStringFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(response)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseStringPublisher(_ type: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseString(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { response in
                _ = subscriber.receive(response)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
