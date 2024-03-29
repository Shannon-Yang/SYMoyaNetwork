//
//  SYMoyaProviderTargetResponseStatePlugin.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/8/10.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// The provider request response status, the status change from the initiation to the end of the network request
public enum SYMoyaProviderResponseState {
    /// The current request state is unknown, eg: the providerResponseStateItems array of SYMoyaProviderTargetResponseStatePlugin is empty, etc.
    case unknown
    /// The network request default state
    case prepare
    /// Network request willSend
    case willSend
    /// Network request completed with status code 200..299
    case success
    /// The network request failed, returning an incorrect network status code, for example: 500
    case failed
    /// Complete the network request, may fail or succeed
    case complete
    /// Process state
    case process
}

/// A request state object holding TargetType
public class SYMoyaProviderTargetResponseStateItem<Target: TargetType> {
    /// provider request state
    public var state: SYMoyaProviderResponseState

    /// The protocol used to define the specifications necessary for a `MoyaProvider`.
    public let target: Target

    /// Class for reifying a target of the `Target` enum unto a concrete `Endpoint`.
    public let endPoint: Endpoint

    // MARK: - Initallization

    init(target: Target, state: SYMoyaProviderResponseState) {
        self.state = state
        self.target = target
        endPoint = MoyaProvider.defaultEndpointMapping(for: target)
    }

    /// Determine whether it is equal to the current item by Target. Note: Initialize endPoint by target for comparison
    ///
    /// - Parameter target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    /// - Returns: Are they equal
    func targetEqual(_ target: Target) -> Bool {
        let endPoint = MoyaProvider.defaultEndpointMapping(for: target)
        return self.endPoint == endPoint
    }
}

// MARK: - Equatable

extension SYMoyaProviderTargetResponseStateItem: Equatable {
    public static func == (lhs: SYMoyaProviderTargetResponseStateItem<Target>, rhs: SYMoyaProviderTargetResponseStateItem<Target>) -> Bool {
        lhs.endPoint == rhs.endPoint
    }
}

/// SYMoyaProvider request state plugin
public final class SYMoyaProviderTargetResponseStatePlugin<Target: TargetType> {
    /// The provider request response status, the status change from the initiation to the end of the network request, default is init .prepare
    public var providerResponseStateItems: [SYMoyaProviderTargetResponseStateItem<Target>]

    // MARK: - Initallization

    public init() {
        providerResponseStateItems = []
    }
}

// MARK: - Private

private extension SYMoyaProviderTargetResponseStatePlugin {
     func addProviderTargetResponseStateItem(_ item: SYMoyaProviderTargetResponseStateItem<Target>) {
        if let index = providerResponseStateItems.firstIndex(of: item) {
            providerResponseStateItems[index] = item
        } else {
            providerResponseStateItems.append(item)
        }
    }
    
    func getProviderResponseStateItemsFirst(_ target: TargetType) -> SYMoyaProviderTargetResponseStateItem<Target>? {
         providerResponseStateItems.first {
            guard let target = target as? Target else {
                fatalError("Type as error")
            }
            return $0.targetEqual(target)
        }
    }
}

// MARK: - PluginType

extension SYMoyaProviderTargetResponseStatePlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let target = target as? Target else {
            fatalError("Type as error")
        }
        let item = SYMoyaProviderTargetResponseStateItem(target: target, state: .prepare)
        addProviderTargetResponseStateItem(item)
        return request
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        let item = getProviderResponseStateItemsFirst(target)
        item?.state = .willSend
    }

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        let item = getProviderResponseStateItemsFirst(target)
        item?.state = .complete
        switch result {
        case .success:
            item?.state = .success
        case .failure:
            item?.state = .failed
        }
    }

    public func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        let item = getProviderResponseStateItemsFirst(target)
        item?.state = .process
        return result
    }
}
