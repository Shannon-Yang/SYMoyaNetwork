//
//  SYMoyaProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/20.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Alamofire
import Foundation
import Moya

/// The provider proxy method is called back. When the completion method of moya is called back, the corresponding proxy method will be called back.
/// When the network request is completed, the requestCompleteFilter method will be called back. When the request fails, the requestFailedFilter method will be called back.
public protocol SYMoyaProviderDelegate: AnyObject {
    /// When moya's completion method is called back, the requestCompleteFilter method will be called back when the network request is completed
    ///
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - response: The response data object after the request is completed
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, target: Target?, requestCompleteFilter response: Moya.Response?)

    /// Delegate callback method when data request success
    ///
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - response: network request success response
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, target: Target?, requestSuccessFilter response: Moya.Response)

    /// Delegate callback method when data request fails
    ///
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - error: network request error message
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, target: Target?, requestFailedFilter error: SYMoyaNetworkError)
}

// A request provider class that inherits from MoyaProvider. Requests can only be made through this class.
open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    /// Network Request Broker Callback Events
    public weak var delegate: SYMoyaProviderDelegate?

    // MARK: Public Properties

    /// The `NetworkCache` used by this manager. It is `NetworkCache.default` by default.
    /// If a cache is specified in `SYMoyaNetwork.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    public let cache: NetworkCache

    // MARK: - Initallization

    /// Initializes a provider.
    override public init(endpointClosure: @escaping EndpointClosure = SYMoyaProvider<Target>.syDefaultEndpointMapping, requestClosure: @escaping RequestClosure = SYMoyaProvider<Target>.defaultRequestMapping, stubClosure: @escaping StubClosure = SYMoyaProvider<Target>.neverStub, callbackQueue: DispatchQueue? = nil, session: Session = SYMoyaProvider<Target>.defaultAlamofireSession(), plugins: [PluginType] = [SYMoyaNetworkLoggerPlugin(), SYMoyaProviderTargetResponseStatePlugin<Target>()], trackInflights: Bool = false) {
        cache = NetworkConfig.sharedInstance.networkCache
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }

    // MARK: - Public

    /// Get the request state of the target by passing in a target, and get the request status through the providerResponseStateItems array object in the SYMoyaProviderTargetResponseStatePlugin object
    /// - Parameter target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    /// - Returns: Target state
    public func responseState(_ target: Target) -> SYMoyaProviderResponseState {
        guard let item = responseStateItem(target) else {
            return .unknown
        }
        return item.state
    }
}

// MARK: - Private

extension SYMoyaProvider {
    private func providerResponseStateItems() -> [SYMoyaProviderTargetResponseStateItem<Target>]? {
        guard let plugin = plugins.first(where: {
            $0 is SYMoyaProviderTargetResponseStatePlugin<Target>
        }) as? SYMoyaProviderTargetResponseStatePlugin<Target> else {
            return nil
        }
        if plugin.providerResponseStateItems.isEmpty {
            return nil
        }
        return plugin.providerResponseStateItems
    }

    private func responseStateItem(_ target: Target) -> SYMoyaProviderTargetResponseStateItem<Target>? {
        let providerResponseStateItems = providerResponseStateItems()
        let endPoint = endpoint(target)
        guard let item = providerResponseStateItems?.first(where: { $0.endPoint == endPoint }) else {
            return nil
        }
        return item
    }

    private func responseStateItem(_ request: URLRequest?) -> SYMoyaProviderTargetResponseStateItem<Target>? {
        guard let urlRequest = request else {
            return nil
        }
        let providerResponseStateItems = providerResponseStateItems()
        guard let item = providerResponseStateItems?.first(where: {
            if let tryURLRequest = try? $0.endPoint.urlRequest() {
                return tryURLRequest == urlRequest
            }
            return false
        }) else {
            return nil
        }
        return item
    }
}

// MARK: - Default

extension SYMoyaProvider {
    /// Returns the `Endpoint` converted to a `Target`.
    public final class func syDefaultEndpointMapping(for target: Target) -> Endpoint {
        let endpoint = Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
        do {
            var request = try endpoint.urlRequest()
            request.timeoutInterval = target.timeoutInterval
            request.mainDocumentURL = target.mainDocumentURL
            request.networkServiceType = target.networkServiceType
            request.allowsCellularAccess = target.allowsCellularAccess
            request.httpShouldHandleCookies = target.httpShouldHandleCookies
            request.httpShouldUsePipelining = target.httpShouldUsePipelining
            request.allowsExpensiveNetworkAccess = target.allowsExpensiveNetworkAccess
            request.allowsConstrainedNetworkAccess = target.allowsConstrainedNetworkAccess
            if #available(iOS 14.5, tvOS 14.5, macOS 11.3, watchOS 7.4, *) {
                request.assumesHTTP3Capable = target.assumesHTTP3Capable
            }
        } catch {
            fatalError("Endpoint failed to get urlRequest, desc: \(error.localizedDescription)")
        }
        return endpoint
    }
}

// MARK: - Req

extension SYMoyaProvider {
    /// Designated request-making method. Returns a `Cancellable` token to cancel the request later.
    @discardableResult
    public func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, shouldCacheIfNeeded: Bool = true, completion: @escaping ((_ result: SYMoyaNetworkResult) -> Void)) -> Cancellable {
        request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            let value = try? result.get()

            // state item
            let item = self.responseStateItem(value?.request)

            // delegate
            self.delegate?.provider(self, target: item?.target, requestCompleteFilter: value)

            switch result {
            case let .success(response):
                // callback filter success
                self.delegate?.provider(self, target: item?.target, requestSuccessFilter: response)

                // Cache
                if shouldCacheIfNeeded {
                    self.cacheIfNeeded(target, response: response)
                }

                let resultResponse = (response, false)
                completion(.success(resultResponse))

            case let .failure(error):
                let e = error.transformToSYMoyaNetworkError()
                // callback filter failure
                self.delegate?.provider(self, target: item?.target, requestFailedFilter: e)

                // completion
                completion(.failure(e))
            }
        })
    }
}
