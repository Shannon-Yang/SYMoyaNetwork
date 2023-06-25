//
//  SYMoyaNetwork+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/26.
//

import Foundation
import RxSwift
import SYMoyaNetwork

extension SYMoyaProvider: ReactiveCompatible {}

extension Reactive where Base: MoyaProviderType {
    
}
