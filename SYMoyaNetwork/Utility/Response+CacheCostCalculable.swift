//
//  Data+CacheCostCalculable.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/26.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension Moya.Response: CacheCostCalculable {
    /// Cost of an Response
    public var cacheCost: Int {
        return self.data.count
    }
}
