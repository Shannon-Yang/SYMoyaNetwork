//
//  SYMoyaProvider+ObjectMapper+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import ObjectMapper
import Combine
import Moya
import SYMoyaNetwork

//MARK: - ObjectMapper Provider Combine
public extension SYMoyaProvider {
    func responseObjectFromCachePublisher<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromDiskCachePublisher<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromMemoryCachePublisher<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObject<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target,serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
    
    func responseObjectsFromCachePublisher<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromDiskCachePublisher<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromMemoryCachePublisher<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse: SYMoyaNetworkDataResponse<[T]> = self.responseObjectsFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObjectsPublisher<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObjects(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
