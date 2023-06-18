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
    
    func responseImageFromCachePublisher(_ target: Target, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<Image>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseImageFromCache(target,callbackQueue: callbackQueue, completion: { dataResponse in
                switch dataResponse.result {
                case .success(let value):
//                    promise(.success(value))
                    debugPrint("🔥🔥🔥🔥🔥----> \(value) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }
    }
    
    func responseImageFromDiskCachePublisher(_ target: Target, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<Image>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseImageFromDiskCache(target, callbackQueue: callbackQueue,completion: { dataResponse in
                switch dataResponse.result {
                case .success(let value):
//                    promise(.success(value))
                    debugPrint("🔥🔥🔥🔥🔥----> \(value) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }
    }
    
    func responseImagePublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> AnyPublisher <SYMoyaNetworkDataResponse<Image>,SYMoyaNetworkError> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseImage(responseDataSourceType,target: target, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
                if case let .failure(error) = dataResponse.result {
                    subscriber.receive(completion: .failure(error))
                } else {
                    _ = subscriber.receive(dataResponse)
                    subscriber.receive(completion: .finished)
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

