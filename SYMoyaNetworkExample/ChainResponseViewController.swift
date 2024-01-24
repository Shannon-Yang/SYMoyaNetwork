//
//  ChainResponseViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/1.
//

import UIKit
import SYMoyaNetwork

class ChainResponseViewController: UIViewController {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.startAnimating()
        
        let chainProvider = SYMoyaChainProvider(targetType: HTTPBinAuth.bearer) { progress in
            debugPrint("🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️----> \(progress) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️")
        }
        SYMoyaChainProviderSession.request(chainMoyaProviderType: chainProvider) { response in
            let targetType = response.targetType
            let result = response.result
            switch targetType {
            case HTTPBinAuth.bearer:
                let json = result.serializerSwiftyJSON().value
                let authenticated = json?["authenticated"].boolValue ?? false
                if authenticated {
                    let nextProvider = SYMoyaChainProvider(targetType: HTTPBinDynamicData.getDelay(delay: 1))
                    return nextProvider
                }
            case HTTPBinDynamicData.getDelay:
                let responseString = result.serializerStringDataResponse(atKeyPath: nil)
                self.contentLabel.text = responseString.value
                self.contentLabel.isHidden = false
                self.indicator.stopAnimating()
            default:
                break
            }
            return nil
        } completion: {
            self.indicator.stopAnimating()
            debugPrint("🔥🔥🔥🔥🔥---->  <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
        }
    }
}