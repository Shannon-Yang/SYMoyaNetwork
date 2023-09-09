//
//  File.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//

import Foundation
import Moya


public protocol ResponseSerializer {
    associatedtype SerializedObject
    func serialize(response: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject>
}
//
//public protocol SYMoyaProviderResponseable {
//    associatedtype Target: SYTargetType
//    
//    func responseFromCache(_ target: Target, responseSerializer serializer: ResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<ResponseSerializer.SerializedObject>) -> Void)
//   
//    func responseFromDiskCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void)
//   
//    func responseFromMemoryCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON>
//
//    
//    @discardableResult
//    func response(_ responseDataSourceType: ResponseDataSourceType, target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable?
//}
