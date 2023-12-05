//
//  SYMoyaProvider+Codable+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import Combine

//MARK: - SwiftyJSON Provider Combine
public extension SYMoyaProvider {
    func responseDecodableObjectFromCachePublisher<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseDecodableObjectFromCache(target, serializer: serializer, callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseDecodableObjectFromDiskCachePublisher<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseDecodableObjectFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue, completion: { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            })
            return nil
        }
    }
    
    func responseDecodableObjectFromMemoryCachePublisher<T: Decodable>(_ target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            let codable: SYMoyaNetworkDataResponse<T> = self.responseDecodableObjectFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(codable)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseDecodableObjectPublisher<T: Decodable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            return self.responseDecodableObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
