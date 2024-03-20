//
//  BatchDataResponseSerializerProtocol.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation

//MARK: - String
/// A `ResponseSerializer` that decodes the response data as a `String`.
public protocol ResponseSerializer {
    associatedtype SerializedObject
    
    /// `SYMoyaNetworkResult` serialize to `SYMoyaNetworkDataResponse`, and its value type is `SerializedObject`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError`
    func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject>
}
