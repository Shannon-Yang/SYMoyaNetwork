//
//  SYMoyaProvider+Reactive.swift
//  ReactiveSYMoyaNetwork
//
//  Created by Shannon Yang on 2023/7/5.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import ReactiveSwift
#if !COCOAPODS
import SYMoyaNetwork
#endif

// MARK: - SYMoyaProvider ReactiveExtensionsProvider

extension SYMoyaProvider: ReactiveExtensionsProvider {}
