//
//  SYMoyaProvider+ObjectMapper+RxSwift.swift
//  SYMoyaRxObjectMapper
//
//  Created by Shannon Yang on 2023/6/24.
//

import Foundation
import SYMoyaNetwork
import RxSwift
import Moya
import ObjectMapper
import SYMoyaObjectMapper

extension SYMoyaProvider {
    
    func responseObjectFromCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        return Observable.create { (observer) -> Disposable in
            self.responseObjectFromCache(target, keyPath: keyPath, context: context, callbackQueue: callbackQueue) { dataResponse in
                observer.onNext(dataResponse)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) -> Observable<SYMoyaNetworkDataResponse<T>> {
        
    }
    
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Observable<SYMoyaNetworkDataResponse<T>> {
        
    }
    
    func responseObjectsFromCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        
    }
    
    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        
    }
    
    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<[T]> {
        
    }
    
    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable? {
        
    }
}
