//
//  SYMoyaProvider+SwiftyJSON+Combine.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/25.
//

#if canImport(Combine)
import Foundation
import Moya
import SwiftyJSON
import Combine

//MARK: - SwiftyJSON Provider Combine
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SYMoyaProvider {
    
    /// Get SwiftyJSON data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseSwiftyJSONFromCachePublisher(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<SwiftyJSON.JSON>,SYMoyaNetworkError> {
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
    
    func responseSwiftyJSONFromDiskCachePublisher(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none) -> Future <SYMoyaNetworkDataResponse<SwiftyJSON.JSON>,SYMoyaNetworkError> {
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
    
    func responseSwiftyJSONPublisher(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> AnyPublisher <SYMoyaNetworkDataResponse<SwiftyJSON.JSON>,SYMoyaNetworkError> {
        return SYMoyaPublisher { [weak self] subscriber in
            return self?.responseSwiftyJSON(responseDataSourceType,target: target, options: opt, callbackQueue: callbackQueue, progress: progress) { dataResponse in
                switch dataResponse.result {
                case .success(let response):
                    _ = subscriber.receive(response.rawValue as! SYMoyaNetworkDataResponse<JSON>)
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
