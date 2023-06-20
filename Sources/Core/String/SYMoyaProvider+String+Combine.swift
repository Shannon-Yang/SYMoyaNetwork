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
    
    func responseStringFromCachePublisher(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<String>,Never> {
        return Future() { [weak self] promise in
            self?.responseStringFromCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue) { dataResponse in
                promise(.success(dataResponse))
            }
        }
    }
    
    func responseStringFromDiskCachePublisher(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<String>,Never> {
        return Future() { [weak self] promise in
            self?.responseStringFromDiskCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue) { dataResponse in
                switch dataResponse.result {
                case .success(let value):
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    func responseStringPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> AnyPublisher <SYMoyaNetworkDataResponse<String>,SYMoyaNetworkError> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseString(responseDataSourceType,target: target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                if case let .failure(error) = dataResponse.result {
                    subscriber.receive(completion: .failure(error))
                } else {
                    _ = subscriber.receive(dataResponse)
                    subscriber.receive(completion: .finished)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
#endif
