//
//  SYMoyaProvider+Codable+Combine.swift
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
 
    func responseCodableObjectFromCachePublisher<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<T>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseCodableObjectFromCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
                switch dataResponse.result {
                case .success(let value):
                    promise(.success(value))
                    debugPrint("🔥🔥🔥🔥🔥----> \(value) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }
    }
    
    func responseCodableObjectFromDiskCachePublisher<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<T>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseCodableObjectFromDiskCache(target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
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
    
    func responseCodableObjectPublisher<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> AnyPublisher <SYMoyaNetworkDataResponse<T>,SYMoyaNetworkError> {
        return SYMoyaPublisher<T> { [weak self] subscriber in
            self?.responseCodableObject(responseDataSourceType,target: target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress) { dataResponse in
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
