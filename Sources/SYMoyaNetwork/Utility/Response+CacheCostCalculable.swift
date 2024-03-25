//
//  Response+CacheCostCalculable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/26.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

// MARK: - CacheCostCalculable

extension Moya.Response: CacheCostCalculable {
    /// Cost of an Response
    public var cacheCost: Int {
        data.count
    }
}
