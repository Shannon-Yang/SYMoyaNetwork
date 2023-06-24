//
//  SYMoyaProvider+HandyJSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

#if canImport(Combine)
import Foundation
import Moya
import Combine
import HandyJSON
import SYMoyaNetwork

//MARK: - HandyJSON Provider Combine
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SYMoyaProvider {
    
    func responseObjectFromCachePublisher<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromDiskCachePublisher<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectFromMemoryCachePublisher<T: HandyJSON>(_ target: Target, designatedPath: String? = nil) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
           let dataResponse: SYMoyaNetworkDataResponse<T> = self.responseObjectFromMemoryCache(target, designatedPath: designatedPath)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObjectPublisher<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<T>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObject(responseDataSourceType,target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
    
    func responseObjectsFromCachePublisher<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]?>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromDiskCachePublisher<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]?>> {
        return SYMoyaPublisher { subscriber in
            self.responseObjectsFromDiskCache(target, designatedPath: designatedPath, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseObjectsFromMemoryCachePublisher<T: HandyJSON>(_ target: Target, designatedPath: String? = nil) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]?>> {
        return SYMoyaPublisher { subscriber in
           let dataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.responseObjectsFromMemoryCache(target, designatedPath: designatedPath)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseObjectsPublisher<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<[T?]?>> {
        return SYMoyaPublisher { subscriber in
            return self.responseObjects(responseDataSourceType,target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
#endif
