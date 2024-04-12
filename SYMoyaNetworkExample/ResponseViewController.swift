//
//  ResponseViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2022/8/9.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import UIKit
import Moya
import SYMoyaNetwork
import Combine
import RxSwift

import RxSYMoyaNetwork
import ReactiveSwift

import SYMoyaRxHandyJSON
import ReactiveSYMoyaNetwork

import SYMoyaRxObjectMapper
import SYMoyaReactiveObjectMapper

enum ResponseCallbackType: Int {
    case normal = 0
    case combine = 1
    case concurrency = 2
    case rx = 3
    case reactive = 4
}

class ResponseViewController: UIViewController {
    let responseType: ResponseType
    
    @IBOutlet weak private var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Normal", forSegmentAt: 0)
            segmentedControl.setTitle("Combine", forSegmentAt: 1)
        }
    }

    @IBOutlet weak private var responseImageView: UIImageView! {
        didSet {
            responseImageView.isHidden = !(responseType == .image)
            contentLabel.isHidden = !(responseImageView.isHidden)
        }
    }
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var contentLabel: UILabel!
    @IBOutlet weak private var indicator: UIActivityIndicatorView!
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
    
    @IBAction private func segmentAction(_ sender: UISegmentedControl) {
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
        switch self.responseType {
        case .string:
            let provider = SYMoyaProvider<HTTPBinDynamicData>()
            switch self.callbackType {
            case .normal:
                provider.responseString(target: .getDelay(delay: 1)) { response in
                    self.contentLabel.text = response.value
                    self.resetState()
                }
            case .combine:
                let publisher = provider.responseStringPublisher(target: .getDelay(delay: 1))
                publisher.sink { response in
                    self.contentLabel.text = response.value
                    self.resetState()
                }.store(in: &cancellables)
            case .concurrency:
                _Concurrency.Task {
                    let response = await provider.responseString(target: .getDelay(delay: 1))
                    self.contentLabel.text = response.value
                    self.resetState()
                }
            case .rx:
                let observable = provider.rx.responseString(target: .getDelay(delay: 1))
                observable.subscribe { response in
                    self.contentLabel.text = response.value
                    self.resetState()
                }.disposed(by: bag)
            case .reactive:
                let producer = provider.reactive.responseString(target: .getDelay(delay: 1))
                producer.start { event in
                    if let value = event.value?.value {
                        self.contentLabel.text = value
                        self.resetState()
                    }
                }
            }
        case .json:
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
                let observable = provider.rx.responseJSON(target: .json)
                observable.subscribe { response in
                    self.contentLabel.text = toJSONString(response: response)
                    self.resetState()
                }.disposed(by: bag)
            case .reactive:
                let producer = provider.reactive.responseJSON(target: .json)
                producer.start { event in
                    if let value = event.value {
                        self.contentLabel.text = toJSONString(response: value)
                        self.resetState()
                    }
                }
            }
            func toJSONString(response: SYMoyaNetworkDataResponse<Any>) -> String? {
                guard let value = response.value else {
                    return nil
                }
                guard let data = try? JSONSerialization.data(withJSONObject: value) else {
                    return nil
                }
                return String(data: data, encoding: .utf8)
            }
        case .image:
            let provider = SYMoyaProvider<HTTPBinImages>()
            switch self.callbackType {
            case .normal:
                provider.responseImage(target: .png) { response in
                    self.responseImageView.image = response.value
                    self.resetState()
                }
            case .combine:
                let publisher = provider.responseImagePublisher(target: .png)
                publisher.sink { response in
                    self.responseImageView.image = response.value
                    self.resetState()
                }.store(in: &cancellables)
            case .concurrency:
                _Concurrency.Task {
                    let response = await provider.responseImage(target: .png)
                    self.responseImageView.image = response.value
                    self.resetState()
                }
            case .rx:
                let observable = provider.rx.responseImage(target: .png)
                observable.subscribe { response in
                    self.responseImageView.image = response.value
                    self.resetState()
                }.disposed(by: bag)
            case .reactive:
                let producer = provider.reactive.responseImage(target: .png)
                producer.start { event in
                    if let value = event.value?.value {
                        self.responseImageView.image = value
                        self.resetState()
                    }
                }
            }
        case .decodable:
            let provider = SYMoyaProvider<HTTPBinDynamicData>()
            switch self.callbackType {
            case .normal:
                provider.responseDecodableObject(target: .getDelay(delay: 1)) { (response: SYMoyaNetworkDataResponse<HttpbinPostCodableModel>) in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }
            case .combine:
                let publisher: SYMoyaPublisher<SYMoyaNetworkDataResponse<HttpbinPostCodableModel>> = provider.responseDecodableObjectPublisher(target: .getDelay(delay: 1))
                publisher.sink { response in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }.store(in: &cancellables)
            case .concurrency:
                _Concurrency.Task {
                    let response: SYMoyaNetworkDataResponse<HttpbinPostCodableModel> = await provider.responseDecodable(target: .getDelay(delay: 1))
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }
            case .rx:
                let observable: Observable<SYMoyaNetworkDataResponse<HttpbinPostCodableModel>> = provider.rx.responseDecodableObject(target: .getDelay(delay: 1))
                observable.subscribe { response in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }.disposed(by: bag)
            case .reactive:
                let producer: SignalProducer<SYMoyaNetworkDataResponse<HttpbinPostCodableModel>, Never> = provider.reactive.responseDecodableObject(target: .getDelay(delay: 1))
                producer.start { event in
                    if let value = event.value?.value {
                        self.contentLabel.text = value.description
                        self.resetState()
                    }
                }
            }
        case .swiftyJSON:
            let provider = SYMoyaProvider<HTTPBinResponseFormats>()
            switch self.callbackType {
            case .normal:
                provider.responseSwiftyJSON(target: .json) { response in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }
            case .combine:
                let publisher = provider.responseSwiftyJSONPublisher(target: .json)
                publisher.sink { response in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }.store(in: &cancellables)
            case .concurrency:
                _Concurrency.Task {
                    let response = await provider.responseSwiftyJSON(target: .json)
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }
            case .rx:
                let observable = provider.rx.responseSwiftyJSON(target: .json)
                observable.subscribe { response in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }.disposed(by: bag)
            case .reactive:
                let producer = provider.reactive.responseSwiftyJSON(target: .json)
                producer.start { event in
                    if let value = event.value?.value?.description {
                        self.contentLabel.text = value.description
                        self.resetState()
                    }
                }
            }
        case .objectMapper:
            let provider = SYMoyaProvider<HTTPBinDynamicData>()
            switch self.callbackType {
            case .normal:
                provider.responseObject(target: .getDelay(delay: 1)) { (response: SYMoyaNetworkDataResponse<HttpbinPostObjectMapperModel>) in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }
            case .combine:
                let publisher: SYMoyaPublisher<SYMoyaNetworkDataResponse<HttpbinPostObjectMapperModel>> = provider.responseObject(target: .getDelay(delay: 1))
                publisher.sink { response in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }.store(in: &cancellables)
            case .concurrency:
                _Concurrency.Task {
                    let response: SYMoyaNetworkDataResponse<HttpbinPostObjectMapperModel> = await provider.responseObject(target: .getDelay(delay: 1))
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }
            case .rx:
                let observable: Observable<SYMoyaNetworkDataResponse<HttpbinPostObjectMapperModel>> = provider.rx.responseObject(target: .getDelay(delay: 1))
                observable.subscribe { response in
                    self.contentLabel.text = response.value?.description
                    self.resetState()
                }.disposed(by: bag)
            case .reactive:
                let producer = provider.reactive.responseString(target: .getDelay(delay: 1))
                producer.start { event in
                    if let value = event.value?.value?.description {
                        self.contentLabel.text = value
                    }
                    self.resetState()
                }
            }
        default:
            break
        }
    }
}
