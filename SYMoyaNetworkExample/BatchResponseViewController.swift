//
//  BatchResponseViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2022/8/9.
//

import UIKit
import SYMoyaNetwork

class BatchResponseViewController: UIViewController {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var session: SYMoyaBatchProviderSession?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let provider = SYMoyaBatchProvider<HTTPBinDynamicData>(targetTypes: [.getDelay(delay: 1),.stream(n: 1)])
        let provider2 = SYMoyaBatchProvider<HTTPBinResponseFormats>(targetTypes: [.brotli,.json,.gzipped])
        
        
        var contentAtt = NSMutableAttributedString(string: "")
        
        indicator.startAnimating()
        session = SYMoyaBatchProviderSession(providers: [provider,provider2])
        session?.request { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressView.progress = Float(progress.fractionCompleted)
            }
        } completion: { [weak self] result in
            self?.contentLabel.isHidden = false
            self?.indicator.stopAnimating()
            switch result {
            case .success(let responses):
                for rep in responses {
                    guard let rep else { continue }
                    switch rep.targetType {
                    case is HTTPBinDynamicData:
                        let dynamicData = rep.targetType as! HTTPBinDynamicData
                        switch dynamicData {
                        case .getDelay:
                            let json = rep.result.serializerJSONDataResponse(failsOnEmptyData: false)
                            let jsonString = self?.toJSONString(response: json)
                            debugPrint("🔥getDelay😀😀----> \(jsonString) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥😀😀")
                        case .stream:
                            let stringRep = rep.result.serializerStringDataResponse(atKeyPath: nil)
                            debugPrint("😯stream----> \(stringRep) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥😀😀")
                        default:
                            break
                        }
                    case is HTTPBinResponseFormats:
                        let responseFormats = rep.targetType as! HTTPBinResponseFormats
                        switch responseFormats {
                        case .brotli:
                            break
                        case .json:
                            break
                        case .gzipped:
                            break
                        }
                    default:
                        break
                    }
                }
            case .failure(let error):
                self?.contentLabel.isHidden = false
                self?.indicator.stopAnimating()
                self?.contentLabel.text = error.errorDescription
            }
        }
    }
}

private extension BatchResponseViewController {
    func toJSONString(response: SYMoyaNetworkDataResponse<Any>) -> String? {
        guard let value = response.value else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        let string = String(data: data, encoding: .utf8)
        return string
    }
}
