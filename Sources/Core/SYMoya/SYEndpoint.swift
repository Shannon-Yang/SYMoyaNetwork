//
//  SYEndpoint.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/8/1.
//

import UIKit
import Moya

/// The endpoint network request status, the status change from the initiation to the end of the network request
public enum SYEndpointResponseState {
   /// The network request has not been completed
   case uncompleted
   /// Network request completed with status code 200..299
   case success
   /// The network request failed, returning an incorrect network status code, for example: 500
   case failed
   /// Complete the network request, may fail or succeed
   case complete
}

/// Inherit Moya.Endpoint, add the endpointResponseState property, and change the response state according to the network request
public class SYEndpoint: Moya.Endpoint {
    
    /// The endpoint network request status, the status change from the initiation to the end of the network request
    var endpointResponseState: SYEndpointResponseState = .uncompleted
}
