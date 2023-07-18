//
//  SYMoyaProvider+ObjectMapper+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

#if canImport(Combine)
import Foundation
import ObjectMapper
import Combine
import Moya
import SYMoyaNetwork

//MARK: - ObjectMapper Provider Combine
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SYMoyaProvider {

    func responseObjectFromCachePublisher<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromDiskCachePublisher<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromDiskCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromMemoryCachePublisher<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
           let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, keyPath: keyPath, context: context)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObject(responseDataSourceType,target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
    
    func responseObjectsFromCachePublisher<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromDiskCachePublisher<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromDiskCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromMemoryCachePublisher<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            let dataResponse: SYMoyaNetworkDataResponse<[T]> = self.responseObjectsFromMemoryCache(target, keyPath: keyPath, context: context)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObjectsPublisher<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T]>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObjects(responseDataSourceType,target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
#endif
