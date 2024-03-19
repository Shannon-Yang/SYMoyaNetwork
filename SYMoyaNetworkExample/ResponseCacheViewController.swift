//
//  ResponseCacheViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/1.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import UIKit
import SYMoyaNetwork

enum ResponseCacheType: Int {
    case server = 0
    case cache = 1
    case diskCache = 2
    case memoryCache = 3
}

class ResponseCacheViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Server", forSegmentAt: 0)
            segmentedControl.setTitle("Cache", forSegmentAt: 1)
            segmentedControl.setTitle("DiskCache", forSegmentAt: 2)
            segmentedControl.setTitle("MemoryCache", forSegmentAt: 3)
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var responseCacheType: ResponseCacheType = .server {
        didSet {
            request()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        request()
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if let type = ResponseCacheType(rawValue: index) {
            self.responseCacheType = type
        }
    }

    @IBAction func clearMemoryCacheAction(_ sender: UIButton) {
        let provider = SYMoyaProvider<HTTPBinDynamicData>()
        provider.clearMemoryCache()
        self.againFetchIfNeeded(responseCacheType: .memoryCache, provider: provider)
    }
    
    @IBAction func clearDiskCacheAction(_ sender: UIButton) {
        let provider = SYMoyaProvider<HTTPBinDynamicData>()
        provider.clearDiskCache {
            self.againFetchIfNeeded(responseCacheType: .diskCache, provider: provider)
        }
    }
    
    @IBAction func clearAllCacheAction(_ sender: UIButton) {
        let provider = SYMoyaProvider<HTTPBinDynamicData>()
        provider.clearCache {
            self.againFetchIfNeeded(responseCacheType: .cache, provider: provider)
        }
    }
}

// MARK: - Private
private extension ResponseCacheViewController {
    func againFetchIfNeeded(responseCacheType: ResponseCacheType, provider: SYMoyaProvider<HTTPBinDynamicData>) {
        switch responseCacheType {
        case .server:
            break
        case .cache:
            if self.responseCacheType == .cache || self.responseCacheType == .memoryCache || self.responseCacheType == .diskCache {
                loadingState()
                // again fetch
                fetchCache(provider: provider)
            }
        case .diskCache:
            if self.responseCacheType == .diskCache {
                loadingState()
                fetchDiskCache(provider: provider)
            }
        case .memoryCache:
            if self.responseCacheType == .memoryCache {
                loadingState()
                fetchMemoryCache(provider: provider)
            }
        }
    }
    
    func loadingState() {
        scrollView.isHidden = true
        indicator.startAnimating()
        contentLabel.text = nil
    }
    
    func resetState() {
        scrollView.isHidden = false
        indicator.stopAnimating()
    }
    
    func request() {
        loadingState()
        let provider = SYMoyaProvider<HTTPBinDynamicData>()
        switch self.responseCacheType {
        case .server:
            provider.responseString(.server, target: .getDelay(delay: 1)) { response in
                switch response.result {
                case .success(let success):
                    self.contentLabel.text = success
                case .failure(let failure):
                    self.contentLabel.text = failure.localizedDescription
                }
                self.resetState()
            }
        case .cache:
            fetchCache(provider: provider)
        case .diskCache:
           fetchDiskCache(provider: provider)
        case .memoryCache:
            fetchMemoryCache(provider: provider)
        }
    }
    
    func fetchDiskCache(provider: SYMoyaProvider<HTTPBinDynamicData>) {
        // Simulate loading
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//            provider.responseStringFromDiskCache(.getDelay(delay: 1)) { response in
//                switch response.result {
//                case .success(let success):
//                    self.contentLabel.text = success
//                case .failure(let failure):
//                    self.contentLabel.text = failure.localizedDescription
//                }
//                self.resetState()
//            }
//        })
    }
    
    func fetchMemoryCache(provider: SYMoyaProvider<HTTPBinDynamicData>) {
        // Simulate loading
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//            let response = provider.responseStringFromMemoryCache(.getDelay(delay: 1), serializer: .defaultStringSerializer)
//            switch response.result {
//            case .success(let success):
//                self.contentLabel.text = success
//            case .failure(let failure):
//                self.contentLabel.text = failure.localizedDescription
//            }
//            self.resetState()
//        })
    }
    
    func fetchCache(provider: SYMoyaProvider<HTTPBinDynamicData>) {
        // Simulate loading
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//            provider.responseStringFromCache(.getDelay(delay: 1)) { response in
//                switch response.result {
//                case .success(let success):
//                    self.contentLabel.text = success
//                case .failure(let failure):
//                    self.contentLabel.text = failure.localizedDescription
//                }
//                self.resetState()
//            }
//        })
    }
}
