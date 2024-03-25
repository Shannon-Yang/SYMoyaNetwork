//
//  SYMoyaNetworkLoggerPlugin.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/23.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

/// Network request log print plugin object
public final class SYMoyaNetworkLoggerPlugin {
    enum NetworkLogMark: String {
        case header = "HEADER --> 🚅🪖"
        case success = "SUCCESS --> ✅😊"
        case fail = "FAIL --> ❌😟"
        case invalidRequest = "INVALID --> ‼️⚠️"
        case time = "TIMELINE --> ⏰⏰"
    }

    /// Log configuration object
    public var configuration: Configuration
    private var start: TimeInterval = 0
    private var end: TimeInterval = 0
    private var willSendRequest: RequestType?

    /// Initializes a NetworkLoggerPlugin.
    public init(configuration: Configuration = NetworkConfig.sharedInstance.logConfiguration) {
        self.configuration = configuration
    }
}

extension SYMoyaNetworkLoggerPlugin.Configuration {
    public struct LogOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        /// The request's method will be logged.
        public static let requestDuration: LogOptions = .init(rawValue: 1 << 0)

        /// The request's body will be logged.
        public static let requestBody: LogOptions = .init(rawValue: 1 << 1)
        /// The request's headers will be logged.
        public static let requestHeaders: LogOptions = .init(rawValue: 1 << 2)

        /// The body of a response that is a success will be logged.
        public static let successResponseBody: LogOptions = .init(rawValue: 1 << 3)
        /// The body of a response that is an error will be logged.
        public static let errorResponseBody: LogOptions = .init(rawValue: 1 << 4)

        // Aggregate options

        /// Only basic components will be logged.
        public static let `default`: LogOptions = [requestBody, requestHeaders, successResponseBody, errorResponseBody]

        /// All components will be logged.
        public static let verbose: LogOptions = [requestDuration, requestBody, requestHeaders, successResponseBody, errorResponseBody]
    }
}

// MARK: - Configuration

extension SYMoyaNetworkLoggerPlugin {
    public struct Configuration {
        // MARK: - Typealiases

        // swiftlint:disable nesting
        public typealias OutputType = (_ target: TargetType, _ items: [String]) -> Void
        // swiftlint:enable nesting

        // MARK: - Properties

        public var formatter: Formatter
        public var output: OutputType
        public var logOptions: LogOptions
        public var shouldPrintRequestLog: Bool = true
        public var items = [String]()

        /// The designated way to instanciate a Configuration.
        ///
        /// - Parameters:
        ///   - formatter: An object holding all formatter closures available for customization.
        ///   - output: A closure responsible for writing the given log entries into your log system.
        ///                    The default value writes entries to the debug console.
        ///   - logOptions: A set of options you can use to customize which request component is logged.
        public init(formatter: Formatter = Formatter(),
                    output: @escaping OutputType = defaultOutput,
                    logOptions: LogOptions = .default,
                    shouldPrintRequestLog: Bool = true) {
            self.formatter = formatter
            self.output = output
            self.logOptions = logOptions
            self.shouldPrintRequestLog = shouldPrintRequestLog
        }

        // MARK: - Defaults

        public static func defaultOutput(target: TargetType, items: [String]) {
            items.forEach { print($0) }
        }
    }
}

extension SYMoyaNetworkLoggerPlugin.Configuration {
    public struct Formatter {
        // MARK: Typealiases

        // swiftlint:disable nesting
        public typealias DataFormatterType = (Data) -> (String)
        public typealias EntryFormatterType = (_ message: String, _ target: SYTargetType) -> String
        // swiftlint:enable nesting

        // MARK: Properties

        public var entry: EntryFormatterType
        public var requestData: DataFormatterType
        public var responseData: DataFormatterType

        /// The designated way to instanciate a Formatter.
        ///
        /// - Parameters:
        ///   - entry: The closure formatting a message into a new log entry.
        ///   - requestData: The closure converting HTTP request's body into a String.
        ///     The default value assumes the body's data is an utf8 String.
        ///   - responseData: The closure converting HTTP response's body into a String.
        ///     The default value assumes the body's data is an utf8 String.
        public init(entry: @escaping EntryFormatterType = defaultEntryFormatter,
                    requestData: @escaping DataFormatterType = defaultDataFormatter,
                    responseData: @escaping DataFormatterType = defaultDataFormatter) {
            self.entry = entry
            self.requestData = requestData
            self.responseData = responseData
        }

        // MARK: Defaults

        public static func defaultDataFormatter(_ data: Data) -> String {
            do {
                guard let rawString = try JSON(data: data).rawString() else {
                    return "## Cannot map data to String ##"
                }
                return rawString
            } catch {
                func buildParameterToDictionary(_ string: String?) -> String? {
                    var dic = [String: Any]()
                    let separateStringArray = string?.components(separatedBy: "&")
                    let separateArray = separateStringArray?.map { $0.components(separatedBy: "=") }.filter { $0.count == 2 }
                    separateArray?.forEach { dic[String($0[0])] = $0[1] }
                    return JSON(dic).rawString()
                }
                guard let rawString = buildParameterToDictionary(String(data: data, encoding: .utf8)) else {
                    return error.localizedDescription
                }
                return rawString
            }
        }

        public static func defaultEntryFormatter(message: String, target: SYTargetType) -> String {
            "\(message)"
        }
    }
}

// MARK: - PluginType

extension SYMoyaNetworkLoggerPlugin: PluginType {
    /// Called to modify a request before sending.
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        request
    }

    /// Called immediately before a request is sent over the network (or stubbed).
    public func willSend(_ request: RequestType, target: TargetType) {
        if configuration.shouldPrintRequestLog {
            start = ProcessInfo.processInfo.systemUptime
            willSendRequest = request
        }
    }

    /// Called after a response has been received, but before the MoyaProvider has invoked its completion handler.
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if configuration.shouldPrintRequestLog {
            end = ProcessInfo.processInfo.systemUptime

            // Request
            if let request = willSendRequest, let syTargetType = target as? SYTargetType {
                logNetworkRequest(request, target: syTargetType) { [weak self] output in
                    self?.configuration.output(target, output)
                }
            }

            // Response
            if let syTargetType = target as? SYTargetType {
                switch result {
                case let .success(response):
                    configuration.output(target, logNetworkResponse(response, target: syTargetType, isFromError: false))
                case let .failure(error):
                    configuration.output(target, logNetworkError(error, target: syTargetType))
                }
            }
        }
    }

    /// Called to modify a result before completion.
    public func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        result
    }
}

// MARK: - Logging

extension SYMoyaNetworkLoggerPlugin {
    private func requestURLString(target: SYTargetType) -> String {
        let requestURL: URL
        let targetPath = target.path
        if target.useCDN {
            if let cdnURL = target.cdnURL {
                if targetPath.isEmpty {
                    requestURL = cdnURL
                } else {
                    requestURL = cdnURL.appendingPathComponent(targetPath)
                }
            } else {
                if targetPath.isEmpty {
                    requestURL = target.baseURL
                } else {
                    requestURL = target.baseURL.appendingPathComponent(targetPath)
                }
            }
        } else {
            if targetPath.isEmpty {
                requestURL = target.baseURL
            } else {
                requestURL = target.baseURL.appendingPathComponent(targetPath)
            }
        }
        return requestURL.absoluteString
    }

    private func logNetworkRequest(_ request: RequestType, target: SYTargetType, completion: @escaping ([String]) -> Void) {
        var headerString = ""
        func header() -> String {
            let headerMark = "\(SYMoyaNetworkLoggerPlugin.NetworkLogMark.header.rawValue)"
            var header = "\(headerMark)"
            header.append(" \n\n↑↑↑↑ [HEADER]: \n\n\(headerString)")
            return header
        }

        func requestInfo() -> String {
            "  RequestMethod: \(target.method.rawValue)  RequestURL: \(request.request?.description ?? "")"
        }

        var parametersString = ""
        func parameters() -> String {
            // Parameter String
            " \n\n↑↑↑↑ [REQUEST]: \n\n\(parametersString)"
        }

        // Request presence check
        let urlString = requestURLString(target: target)
        guard let httpRequest = request.request, !urlString.isEmpty else {
            headerString = "(invalid request)"
            var des = header()
            des.append("\(SYMoyaNetworkLoggerPlugin.NetworkLogMark.invalidRequest.rawValue)")
            des.append(requestInfo())
            des.append(headerString)
            completion([configuration.formatter.entry(des, target)])
            return
        }

        // Adding log entries for each given log option
        var output = [String]()

        if configuration.logOptions.contains(.requestHeaders) {
            var allHeaders = request.sessionHeaders
            if let httpRequestHeaders = httpRequest.allHTTPHeaderFields {
                allHeaders.merge(httpRequestHeaders) { $1 }
            }
            headerString = allHeaders.description
            let header = header()
            output.append(configuration.formatter.entry(header, target))
        }

        if configuration.logOptions.contains(.requestBody) {
            if let bodyStream = httpRequest.httpBodyStream {
                parametersString = " \n\n↑↑↑↑ [BODYSTREAM]: \n{\n\(bodyStream.description)\n}"
                if let body = httpRequest.httpBody {
                    let string = configuration.formatter.requestData(body)
                    parametersString.append(" \n\n↑↑↑↑ [HTTPBODY]: \n{\n\(string)\n}")
                }
                let parameters = parameters()
                output.append(configuration.formatter.entry(parameters, target))
            }

            if let body = httpRequest.httpBody {
                parametersString = configuration.formatter.requestData(body)
                let parameters = parameters()
                output.append(configuration.formatter.entry(parameters, target))
            }
        }
        completion(output)
    }

    private func timeline() -> String {
        func generateTimelineResponseDescription(networkTime: TimeInterval) -> String {
            let totalDuration = networkTime
            let totalDurationString = String(format: "%.6f", totalDuration)
            return "{ \n  Request Duration: \(String(format: "%.6f", networkTime)) secs \n  Total Duration: \(totalDurationString) secs\n }"
        }
        return "\nTimeline\(NetworkLogMark.time.rawValue): \n\(generateTimelineResponseDescription(networkTime: end - start))"
    }

    private func logNetworkResponse(_ response: Moya.Response, target: SYTargetType, isFromError: Bool) -> [String] {
        // Adding log entries for each given log option
        var output = [String]()

        func requestInfo() -> String {
            "  StatusCode: \(response.statusCode)  RequestMethod: \(target.method.rawValue)  RequestURL: \(response.request?.description ?? "")"
        }

        var resultJSONString = ""
        func responseDes(mark: NetworkLogMark) -> String {
            var responseDes = "\n\(mark.rawValue)"
            let info = requestInfo()
            responseDes.append(info)
            responseDes.append(" \n\n↓↓↓↓ [RESPONSE]: \n")
            responseDes.append("\nData: \(response.data.count) bytes\n")
            responseDes.append("\nResult: \(resultJSONString)\n")
            if configuration.logOptions.contains(.requestDuration) {
                responseDes.append(timeline())
            }
            return responseDes
        }

        if (isFromError && configuration.logOptions.contains(.errorResponseBody))
            || configuration.logOptions.contains(.successResponseBody) {
            resultJSONString = configuration.formatter.responseData(response.data)
            let des = responseDes(mark: .success)
            output.append(configuration.formatter.entry(des, target))
        } else {
            let des = responseDes(mark: .fail)
            output.append(configuration.formatter.entry(des, target))
        }

        return output
    }

    private func logNetworkError(_ error: MoyaError, target: SYTargetType) -> [String] {
        // Some errors will still have a response, like errors due to Alamofire's HTTP code validation.
        if let moyaResponse = error.response {
            return logNetworkResponse(moyaResponse, target: target, isFromError: true)
        } else {
            // Errors without an HTTPURLResponse are those due to connectivity, time-out and such.
            func responseDes(mark: NetworkLogMark) -> String {
                var responseDes = "\n\(mark.rawValue)"
                responseDes.append(" \n\n↓↓↓↓ [RESPONSE]: \n")
                responseDes.append("\nData: 0 bytes\n")
                responseDes.append("\nResult: \(error.errorDescription ?? "")\n")
                if configuration.logOptions.contains(.requestDuration) {
                    responseDes.append(timeline())
                }
                return responseDes
            }
            return [configuration.formatter.entry(responseDes(mark: .fail), target)]
        }
    }
}
