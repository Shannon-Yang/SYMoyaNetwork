//
//  ChainResponseViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/1.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import UIKit
import SYMoyaNetwork

class ChainResponseViewController: UIViewController {
    @IBOutlet weak private var contentLabel: UILabel!
    @IBOutlet weak private var indicator: UIActivityIndicatorView!

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
                    return SYMoyaChainProvider(targetType: HTTPBinDynamicData.getDelay(delay: 1))
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
