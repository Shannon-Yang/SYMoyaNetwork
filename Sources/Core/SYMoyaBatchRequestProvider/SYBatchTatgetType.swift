//
//  SYBatchTatgetType.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//

import Foundation
import Moya

//MARK: - SYBatchTatgetType
public protocol SYBatchTatgetType: SYTargetType {
    associatedtype Serializer: ResponseSerializer
    var serializer: Serializer? { get }
}

extension SYBatchTatgetType {
    var serializer: Serializer? {
        return nil
    }
}

