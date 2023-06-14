//
//  SYMoyaProvider+String+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/1.
//

#if canImport(Combine)
import Foundation
import Moya
import SwiftyJSON
import Combine

//MARK: - SwiftyJSON Provider Combine
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SYMoyaProvider {
    
   
    func responseStringFromCachePublisher(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<String>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseStringFromCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue) { dataResponse in
                switch dataResponse.result {
                case .success(let value):
//                    promise(.success(value))
                    debugPrint("🔥🔥🔥🔥🔥----> \(value) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    func responseStringFromDiskCachePublisher(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<String>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseStringFromDiskCache(target, atKeyPath: atKeyPath, callbackQueue: callbackQueue) { dataResponse in
                switch dataResponse.result {
                case .success(let value):
//                    promise(.success(value))
                    debugPrint("🔥🔥🔥🔥🔥----> \(value) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    func responseStringPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> AnyPublisher <SYMoyaNetworkDataResponse<String>,SYMoyaNetworkError> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseString(responseDataSourceType,target: target, atKeyPath: atKeyPath, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                switch dataResponse.result {
                case .success(let response):
                    _ = subscriber.receive(response.rawValue as! SYMoyaNetworkDataResponse<String>)
                    subscriber.receive(completion: .finished)
                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
#endif
