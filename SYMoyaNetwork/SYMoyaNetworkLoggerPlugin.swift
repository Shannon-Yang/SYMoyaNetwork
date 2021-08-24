//
//  SYMoyaNetworkLoggerPlugin.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/23.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

public final class SYMoyaNetworkLoggerPlugin {

    public var configuration: Configuration

    /// Initializes a NetworkLoggerPlugin.
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    
//    shouldPrintRequestLog
}


public extension SYMoyaNetworkLoggerPlugin.Configuration {
    struct LogOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        /// The request's method will be logged.
        public static let requestMethod: LogOptions = LogOptions(rawValue: 1 << 0)
        
        public static let requestURL: LogOptions = LogOptions(rawValue: 1 << 0)
        
        public static let requestDuration: LogOptions = LogOptions(rawValue: 1 << 0)
        
        /// The request's body will be logged.
        public static let requestBody: LogOptions = LogOptions(rawValue: 1 << 1)
        /// The request's headers will be logged.
        public static let requestHeaders: LogOptions = LogOptions(rawValue: 1 << 2)
        
        
        
        /// The body of a response that is a success will be logged.
        public static let successResponseBody: LogOptions = LogOptions(rawValue: 1 << 4)
        /// The body of a response that is an error will be logged.
        public static let errorResponseBody: LogOptions = LogOptions(rawValue: 1 << 5)
        
        
        
        public static let serializationDuration: LogOptions = LogOptions(rawValue: 1 << 0)
        
        public static let totalDuration: LogOptions = LogOptions(rawValue: 1 << 0)
        
        public static let destinationURL: LogOptions = LogOptions(rawValue: 1 << 0)
        
        public static let resumeData: LogOptions = LogOptions(rawValue: 1 << 0)
        
        
        //Aggregate options
        
        /// Only basic components will be logged.
        public static let `default`: LogOptions = [requestMethod, requestURL, requestHeaders, requestBody, successResponseBody, errorResponseBody]
        
        /// All components will be logged.
        public static let verbose: LogOptions = [requestMethod, requestURL, requestDuration, requestHeaders, requestBody,
                                                 successResponseBody, errorResponseBody, serializationDuration, totalDuration, destinationURL, resumeData]
    }
}


// MARK: - Configuration
public extension SYMoyaNetworkLoggerPlugin {
    
    struct Configuration {

        // MARK: - Typealiases
        // swiftlint:disable nesting
        public typealias OutputType = (_ target: TargetType, _ items: [String]) -> Void
        // swiftlint:enable nesting

        // MARK: - Properties

        public var formatter: Formatter
        public var output: OutputType
        public var logOptions: LogOptions

        /// The designated way to instanciate a Configuration.
        ///
        /// - Parameters:
        ///   - formatter: An object holding all formatter closures available for customization.
        ///   - output: A closure responsible for writing the given log entries into your log system.
        ///                    The default value writes entries to the debug console.
        ///   - logOptions: A set of options you can use to customize which request component is logged.
        public init(formatter: Formatter = Formatter(),
                    output: @escaping OutputType = defaultOutput,
                    logOptions: LogOptions = .default) {
            self.formatter = formatter
            self.output = output
            self.logOptions = logOptions
        }

        // MARK: - Defaults

        public static func defaultOutput(target: TargetType, items: [String]) {
            for item in items {
                print(item, separator: ",", terminator: "\n")
            }
        }
    }
    
}


public extension NetworkLoggerPlugin.Configuration {
    
    struct Formatter {

        // MARK: Typealiases
        // swiftlint:disable nesting
        public typealias DataFormatterType = (Data) -> (String)
        public typealias EntryFormatterType = (_ identifier: String, _ message: String, _ target: TargetType) -> String
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
            return String(data: data, encoding: .utf8) ?? "## Cannot map data to String ##"
        }

        public static func defaultEntryFormatter(identifier: String, message: String, target: TargetType) -> String {
            let date = defaultEntryDateFormatter.string(from: Date())
            return "Moya_Logger: [\(date)] \(identifier): \(message)"
        }

        static var defaultEntryDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            return formatter
        }()
    }
    
}
/*
extension SYMoyaNetworkLoggerPlugin: PluginType {
    /// Called to modify a request before sending.
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }

    /// Called immediately before a request is sent over the network (or stubbed).
    func willSend(_ request: RequestType, target: TargetType) {
        
    }

    /// Called after a response has been received, but before the MoyaProvider has invoked its completion handler.
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
    }

    /// Called to modify a result before completion.
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        
    }
}*/


// MARK: - Private

private extension SYMoyaNetworkLoggerPlugin {
    
    /*
    func logNetworkRequest(_ request: RequestType, target: TargetType, completion: @escaping ([String]) -> Void) {
        //cURL formatting
        if configuration.logOptions.contains(.formatRequestAscURL) {
            _ = request.cURLDescription { [weak self] output in
                guard let self = self else { return }

                completion([self.configuration.formatter.entry("Request", output, target)])
            }
            return
        }

        //Request presence check
        guard let httpRequest = request.request else {
            completion([configuration.formatter.entry("Request", "(invalid request)", target)])
            return
        }

        // Adding log entries for each given log option
        var output = [String]()

        output.append(configuration.formatter.entry("Request", httpRequest.description, target))

        if configuration.logOptions.contains(.requestHeaders) {
            var allHeaders = request.sessionHeaders
            if let httpRequestHeaders = httpRequest.allHTTPHeaderFields {
                allHeaders.merge(httpRequestHeaders) { $1 }
            }
            output.append(configuration.formatter.entry("Request Headers", allHeaders.description, target))
        }

        if configuration.logOptions.contains(.requestBody) {
            if let bodyStream = httpRequest.httpBodyStream {
                output.append(configuration.formatter.entry("Request Body Stream", bodyStream.description, target))
            }

            if let body = httpRequest.httpBody {
                let stringOutput = configuration.formatter.requestData(body)
                output.append(configuration.formatter.entry("Request Body", stringOutput, target))
            }
        }

        if configuration.logOptions.contains(.requestMethod),
            let httpMethod = httpRequest.httpMethod {
            output.append(configuration.formatter.entry("HTTP Request Method", httpMethod, target))
        }

        completion(output)
    }*/
}


func generateResponseDescription(_ target: TargetType, urlRequest: URLRequest?, response: HTTPURLResponse?, fileURL: URL? = nil, resumeData: Data? = nil, data: Data? = nil, error: Error?) -> String {
    
    var mark = "✅😊"
    
    var description = "\(mark)"
    
    description.append("  RequestMethod: \(urlRequest?.httpMethod ?? "")  RequestURL: \(urlRequest?.description ?? "")")
    
//    switch target.task {
//    case .requestPlain:
//
//    case .
//    default:
//        <#code#>
//    }

    /*
    let parameters = SYNetworkingConfig.sharedInstance.uniformParameters?.merged(with: request.parameters) ?? request.parameters
    var parametersString = ""
    if let jsonParameters = parameters,let string = JSON(data: jsonParameters).rawString() {
        parametersString = string
    }
    description.append(" \n\n↑↑↑↑ [REQUEST]: \n\n\(parametersString)")
    
    description.append(" \n\n↓↓↓↓ [RESPONSE]: \n")
    
    if let fileURL = fileURL {
        description.append("\nFileURL: \(fileURL.absoluteString)")
    }
    
    if let resumeData = resumeData {
        description.append("\nResumeData: \(resumeData.count) bytes")
    }
    
    if let error = error {
        mark = "❌😟"
        description.append("\nError❗️: \(error.localizedDescription)")
        return description
    }
    var resultJSONString: String?
    if let resultData = data {
        resultJSONString = JSON(resultData).rawString()
    }
    description.append("\nData: \(data?.count ?? 0) bytes\n\nResult: \(resultJSONString ?? "")\n")
    
    return description */
    return ""
}

