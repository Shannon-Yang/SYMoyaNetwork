//
//  SYMoyaProviderSessionTypealias.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/12/13.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation

/// Response wrapper object for `SYMoyaBatchProviderSession` and `SYMoyaChainProviderSession`, used for responses to batch and chain requests
public typealias SYMoyaProviderSessionResponse = (targetType: SYTargetType, result: SYMoyaNetworkResult)
