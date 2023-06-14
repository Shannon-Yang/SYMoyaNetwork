//
//  SYMoyaProvider+Codable+Combine.swift
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
 
    func responseCodableObjectFromCachePublisher<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<T>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseSwiftyJSONFromCache(target, options: opt, callbackQueue: callbackQueue) { dataResponse in
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
    
    func responseCodableObjectFromDiskCachePublisher<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<T>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseSwiftyJSONFromDiskCache(target, options: opt, callbackQueue: callbackQueue) { dataResponse in
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
    
    func responseCodableObjectPublisher<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> AnyPublisher <SYMoyaNetworkDataResponse<T>,SYMoyaNetworkError> {
        return SYMoyaPublisher<T> { [weak self] subscriber in
            self?.responseCodableObject(responseDataSourceType,target: target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                switch dataResponse.result {
                case .success(let response):
                    _ = subscriber.receive(response.rawValue as! SYMoyaNetworkDataResponse<T>)
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
