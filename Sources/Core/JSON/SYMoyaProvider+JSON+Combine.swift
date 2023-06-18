//
//  SYMoyaProvider+JSON+Combine.swift
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
    
    func responseJSONFromCachePublisher(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<Any>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseJSONFromCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
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
    
    func responseJSONFromCacheDiskCachePublisher(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<Any>,SYMoyaNetworkError> {
        return Future() { [weak self] promise in
            self?.responseJSONFromDiskCache(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: { dataResponse in
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
    
    func responseJSONPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> AnyPublisher <SYMoyaNetworkDataResponse<Any>,SYMoyaNetworkError> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseJSON(target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
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
