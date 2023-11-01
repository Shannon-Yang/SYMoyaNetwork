//
//  ResponseViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2022/8/9.
//

import UIKit
import Moya
import SYMoyaNetwork
import Combine
import RxSwift
import RxSYMoyaNetwork

enum ResponseCallbackType: Int {
    case normal = 0
    case combine = 1
    case concurrency = 2
    case rx = 3
    case reactive = 4
}

class ResponseViewController: UIViewController {
    let responseType: ResponseType
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Normal", forSegmentAt: 0)
            segmentedControl.setTitle("Combine", forSegmentAt: 1)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    private var callbackType: ResponseCallbackType = .normal {
        didSet {
            request()
        }
    }
    private var cancellables = Set<AnyCancellable>()
    private let bag = DisposeBag()
    
    // MARK: - Initallization
    init(responseType: ResponseType) {
        self.responseType = responseType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if let type = ResponseCallbackType(rawValue: index) {
            self.callbackType = type
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Example Detail"
        self.segmentedControl.insertSegment(withTitle: "Concurrency", at: 2, animated: false)
        self.segmentedControl.insertSegment(withTitle: "Rx", at: 3, animated: false)
        self.segmentedControl.insertSegment(withTitle: "Reactive", at: 4, animated: false)
        self.request()
        
//        let provider = SYMoyaBatchProvider<HTTPBinDynamicData>(targetTypes: [.getDelay(delay: 1),.stream(n: 1)])
//        let provider2 = SYMoyaBatchProvider<HTTPBinResponseFormats>(targetTypes: [.brotli,.json,.gzipped])
//        self.session = SYMoyaBatchProviderSession(providers: [provider,provider2])
        
//        let pro = SYMoyaProvider<GitHub>()
//        pro.responseString(target: .zen) { dataResponse in
//            debugPrint("🔥🔥🔥🔥🔥----> \(dataResponse) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
//            let s = pro.responseState(.zen)
//            debugPrint("🔥🔥🔥🔥🔥----> \(s) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
//        }
//       let s = pro.responseState(.zen)
//        debugPrint("🔥🔥🔥🔥🔥----> \(s) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
    }
}

// MARK: - Private
private extension ResponseViewController {

    func loadingState() {
        scrollView.isHidden = true
        indicator.startAnimating()
    }
    
    func resetState() {
        scrollView.isHidden = false
        indicator.stopAnimating()
    }
    
    func request() {
        loadingState()
//        switch self.responseType {
//        case .string:
//            let provider = SYMoyaProvider<HTTPBinDynamicData>()
//            switch self.callbackType {
//            case .normal:
//                provider.responseString(target: .getDelay(delay: 1)) { response in
//                    self.contentLabel.text = response.value
//                    self.resetState()
//                }
//            case .combine:
//                let publisher = provider.responseStringPublisher(target: .getDelay(delay: 1))
//                publisher.sink { response in
//                    self.contentLabel.text = response.value
//                    self.resetState()
//                }.store(in: &cancellables)
//            case .concurrency:
//                _Concurrency.Task {
//                    let response = await provider.responseString(target: .getDelay(delay: 1))
//                    self.contentLabel.text = response.value
//                    self.resetState()
//                }
//            }
//        case .json:
            let provider = SYMoyaProvider<HTTPBinResponseFormats>()
            switch self.callbackType {
            case .normal:
                provider.responseJSON(target: .json) { response in
                    self.contentLabel.text = toJSONString(response: response)
                    self.resetState()
                }
            case .combine:
                let publisher = provider.responseJSONPublisher(target: .json)
                publisher.sink { response in
                    self.contentLabel.text = toJSONString(response: response)
                    self.resetState()
                }.store(in: &cancellables)
            case .concurrency:
                _Concurrency.Task {
                    let response = await provider.responseJSON(target: .json)
                    self.contentLabel.text = toJSONString(response: response)
                    self.resetState()
                }
            case .rx:
                let observable: Observable<SYMoyaNetworkDataResponse<Any>> = provider.responseJSON(target: .json)
                observable.subscribe { event in
                    
                }.disposed(by: bag)
            case .reactive:
                break
            }
            func toJSONString(response: SYMoyaNetworkDataResponse<Any>) -> String? {
                guard let value = response.value else { return nil }
                guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
                let string = String(data: data, encoding: .utf8)
                return string
            }
//        case .image:
//            <#code#>
//        case .decodable:
//            <#code#>
//        case .swiftyJSON:
//            <#code#>
//        case .handyJSON:
//            <#code#>
//        case .objectMapper:
//            <#code#>
//        default:
//            break
//        }
    }
}
