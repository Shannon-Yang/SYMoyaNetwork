//
//  SYBatchTatgetType.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//

import Foundation
import Moya

public protocol BatchDataResponseSerializerProtocol {
    associatedtype SerializedObject
    func serialize(response: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject>
}

public protocol SYBatchTatgetType: SYTargetType {
    associatedtype Serializer: BatchDataResponseSerializerProtocol
    var serializer: Serializer? { get }
}

extension SYBatchTatgetType {
    var serializer: Serializer? {
        return nil
    }
}
