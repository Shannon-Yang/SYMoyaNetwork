//
//  SwiftyJSONResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2024/3/20.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A `ResponseSerializer` that decodes the response data as a `SwiftyJSON`.
public class SwiftyJSONResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = SwiftyJSON.JSON
    private let opt: JSONSerialization.ReadingOptions
    
    /// Init SwiftyJSONResponseSerializer
    ///
    /// - Parameter opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    public init(ptions opt: JSONSerialization.ReadingOptions = []) {
        self.opt = opt
    }
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<SwiftyJSON.JSON>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `SwiftyJSON.JSON`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerSwiftyJSON(ptions: opt)
    }
}

public extension ResponseSerializer where Self == SwiftyJSONResponseSerializer {
    /// Default serializer object
    static var defaultSwiftyJSONSerializer: SwiftyJSONResponseSerializer {
        SwiftyJSONResponseSerializer()
    }
    
    /// Create a SwiftyJSONResponseSerializer
    ///
    /// - Parameter opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `SwiftyJSON`.
    static func swiftyJSON(ptions opt: JSONSerialization.ReadingOptions = []) -> SwiftyJSONResponseSerializer {
        return SwiftyJSONResponseSerializer(ptions: opt)
    }
}
