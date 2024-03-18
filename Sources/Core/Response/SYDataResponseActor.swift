//
//  SYDataResponseActor.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/26.
//

import Foundation
import Moya
import SwiftyJSON

/// <#Description#>
public actor SYDataResponseActor<Target: SYTargetType> {
    
    /// <#Description#>
    public var cancellable: Moya.Cancellable?
    
    /// <#Description#>
    public let provider: SYMoyaProvider<Target>
    
    
    /// <#Description#>
    /// - Parameter provider: <#provider description#>
    public init(provider: SYMoyaProvider<Target>) {
        self.provider = provider
    }
    
    
    /// <#Description#>
    public func cancel() {
        cancellable?.cancel()
    }
}

extension SYDataResponseActor {
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    ///   - completion: <#completion description#>
    func responseSwiftyJSON(_ type: ResponseDataSourceType = .server, target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        cancellable = provider.responseSwiftyJSON(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
            completion(dataResponse)
        })
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    ///   - completion: <#completion description#>
    func responseJSON(_ type: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        cancellable = provider.responseJSON(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    ///   - completion: <#completion description#>
    func responseString(_ type: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<String>) -> Void) {
        cancellable = provider.responseString(type,target: target,serializer: serializer,callbackQueue: callbackQueue,progress: progress, completion: completion)
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    ///   - completion: <#completion description#>
    func responseImage(_ type: ResponseDataSourceType = .server, target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        cancellable = provider.responseImage(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    ///   - completion: <#completion description#>
    func responseDecodableObject<T: Decodable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseDecodableObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
