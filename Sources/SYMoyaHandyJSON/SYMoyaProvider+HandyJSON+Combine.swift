//
//  SYMoyaProvider+HandyJSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

import Foundation
import Moya
import Combine
import HandyJSON
import SYMoyaNetwork

//MARK: - HandyJSON Provider Combine
public extension SYMoyaProvider {
    func responseObjectFromCachePublisher<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromDiskCachePublisher<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromMemoryCachePublisher<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObjectPublisher<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
    
    func responseObjectsFromCachePublisher<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromDiskCachePublisher<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromDiskCache(target, serializer: serializer, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromMemoryCachePublisher<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse: SYMoyaNetworkDataResponse<[T?]> = self.responseObjectsFromMemoryCache(target, serializer: serializer)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObjectsPublisher<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObjects(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
