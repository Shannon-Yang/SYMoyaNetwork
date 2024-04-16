//
//  SYMoyaProvider+Rx.swift
//  RxSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import RxSwift
#if !COCOAPODS
import SYMoyaNetwork
#endif

// MARK: - SYMoyaProvider ReactiveCompatible

extension SYMoyaProvider: ReactiveCompatible {}
