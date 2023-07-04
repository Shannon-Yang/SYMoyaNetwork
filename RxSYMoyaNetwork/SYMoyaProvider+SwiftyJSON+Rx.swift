//
//  SYMoyaProvider+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/29.
//

import Foundation
import RxSwift
import SYMoyaNetwork
import Moya
import SwiftyJSON

extension Reactive where Base: SYMoyaProviderJSONType {
    func responseSwiftyJSONFromCache(_ target: SYTargetType, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none) -> Observable<SYMoyaNetworkDataResponse<SwiftyJSON.JSON>> {
        return Observable.create { [weak base] observer -> Disposable in
            self.base.responseSwiftyJSONFromCache(target, options: opt, callbackQueue: callbackQueue) { dataResponse in
                observer.on(.next(dataResponse))
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }
}

//extension Reactive {
    
 
//}
