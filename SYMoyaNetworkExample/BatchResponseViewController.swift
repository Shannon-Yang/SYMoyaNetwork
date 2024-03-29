//
//  BatchResponseViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2022/8/9.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import SYMoyaNetwork
import UIKit

class BatchResponseViewController: UIViewController {
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    @IBOutlet private var progressView: UIProgressView!

    var session: SYMoyaBatchProviderSession?
    override func viewDidLoad() {
        super.viewDidLoad()

        let provider = SYMoyaBatchProvider<HTTPBinDynamicData>(targetTypes: [.getDelay(delay: 1),
                                                                             .stream(n: 1)])
        let provider2 = SYMoyaBatchProvider<HTTPBinResponseFormats>(targetTypes: [.brotli,
                                                                                  .json,
                                                                                  .gzipped])

        let contentString = NSMutableAttributedString(string: String(), attributes: [.foregroundColor: UIColor.black])
        indicator.startAnimating()
        session = SYMoyaBatchProviderSession(providers: [provider,
                                                         provider2])
        session?.request { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressView.progress = Float(progress.fractionCompleted)
            }
        } completion: { [weak self] result in
            self?.contentLabel.isHidden = false
            self?.indicator.stopAnimating()
            switch result {
            case let .success(responses):
                for rep in responses {
                    guard let rep else { continue }
                    switch rep.targetType {
                    case is HTTPBinDynamicData:
                        guard let dynamicData = rep.targetType as? HTTPBinDynamicData else {
                            fatalError("Test target must be HTTPBinDynamicData")
                        }
                        switch dynamicData {
                        case .getDelay:
                            let json = rep.result.serializerJSONDataResponse(failsOnEmptyData: false)
                            if let jsonString = self?.toJSONString(response: json) {
                                contentString.append(NSAttributedString(string: dynamicData.path + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))

                                contentString.append(NSAttributedString(string: jsonString + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
                            }
                        case .stream:
                            if let string = rep.result.serializerStringDataResponse(atKeyPath: nil).value {
                                contentString.append(NSAttributedString(string: dynamicData.path + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))

                                contentString.append(NSAttributedString(string: string + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
                            }
                        default:
                            break
                        }
                    case is HTTPBinResponseFormats:
                        guard let responseFormats = rep.targetType as? HTTPBinResponseFormats else {
                            fatalError("Test target must be HTTPBinResponseFormats")
                        }
                        switch responseFormats {
                        case .brotli:
                            let json = rep.result.serializerJSONDataResponse(failsOnEmptyData: false)
                            if let jsonString = self?.toJSONString(response: json) {
                                contentString.append(NSAttributedString(string: responseFormats.path + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))

                                contentString.append(NSAttributedString(string: jsonString + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
                            }
                        case .json:
                            let json = rep.result.serializerJSONDataResponse(failsOnEmptyData: false)
                            if let jsonString = self?.toJSONString(response: json) {
                                contentString.append(NSAttributedString(string: responseFormats.path + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))

                                contentString.append(NSAttributedString(string: jsonString + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
                            }
                        case .gzipped:
                            if let string = rep.result.serializerStringDataResponse(atKeyPath: nil).value {
                                contentString.append(NSAttributedString(string: responseFormats.path + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))

                                contentString.append(NSAttributedString(string: string + "\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
                            }
                        }
                    default:
                        break
                    }
                }
                self?.contentLabel.attributedText = contentString
            case let .failure(error):
                self?.contentLabel.isHidden = false
                self?.indicator.stopAnimating()
                self?.contentLabel.text = error.errorDescription
            }
        }
    }
}

private extension BatchResponseViewController {
    func toJSONString(response: SYMoyaNetworkDataResponse<Any>) -> String? {
        guard let value = response.value else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: value) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
