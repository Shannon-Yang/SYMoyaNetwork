//
//  SYSerializableTatgetType.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/3.
//

import Foundation
import Moya

//MARK: - SYSerializableTatgetType
public protocol SYSerializableTatgetType: SYTargetType {
    var serializer: any ResponseSerializer { get }
}

extension SYSerializableTatgetType {
    var serializer: any ResponseSerializer {
        return .defaultJSONSerializer
    }
}

