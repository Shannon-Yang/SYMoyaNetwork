//
//  SYMoyaProvider+String+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

#if canImport(Combine)
import Foundation
import Moya
import Combine

//MARK: - SwiftyJSON Provider Combine
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SYMoyaProvider {
    
    func responseStringFromCachePublisher(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            self.responseStringFromCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseStringFromDiskCachePublisher(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in
            self.responseStringFromDiskCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
            return nil
        }
    }
    
    func responseStringFromMemoryCachePublisher(_ target: Target, atKeyPath: String? = nil) -> SYMoyaPublisher<SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { subscriber in 
            let dataResponse = self.responseStringFromMemoryCache(target, atKeyPath: atKeyPath)
            _ = subscriber.receive(dataResponse)
            subscriber.receive(completion: .finished)
            return nil
        }
    }
    
    func responseStringPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> SYMoyaPublisher <SYMoyaNetworkDataResponse<String>> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseString(responseDataSourceType,target: target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                _ = subscriber.receive(dataResponse)
                subscriber.receive(completion: .finished)
            }
        }
    }
}
#endif
