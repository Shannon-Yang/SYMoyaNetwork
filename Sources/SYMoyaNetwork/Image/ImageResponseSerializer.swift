//
//  ImageResponseSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2024/3/20.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// A `ResponseSerializer` that decodes the response data as a `Image`.
public class ImageResponseSerializer: ResponseSerializer {
    public typealias SerializedObject = Image
    
    /// `SYMoyaNetworkResult` serialize `SYMoyaNetworkDataResponse<Image>`
    ///
    /// - Parameter result: A data request result object with `SYMoyaNetworkResultResponse` and `SYMoyaNetworkError`.
    /// - Returns: An object specifically referring to `SYDataResponse` whose failure value is `SYMoyaNetworkError` and success value is `Image`
    public func serialize(result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<SerializedObject> {
        return result.serializerImageDataResponse()
    }
}

public extension ResponseSerializer where Self == ImageResponseSerializer {
    /// Default serializer object
    static var defaultImageSerializer: ImageResponseSerializer {
        ImageResponseSerializer()
    }
    
    /// Create a DecodableResponseSerializer
    ///
    /// - Returns: A `ResponseSerializer` that decodes the response data as a `Image`.
    static func image() -> ImageResponseSerializer {
        return ImageResponseSerializer()
    }
}
