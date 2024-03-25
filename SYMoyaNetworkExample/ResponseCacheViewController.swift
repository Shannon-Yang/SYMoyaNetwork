//
//  ResponseCacheViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/1.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import SYMoyaNetwork
import UIKit

enum ResponseCacheType: Int {
    case server = 0
    case cache = 1
    case diskCache = 2
    case memoryCache = 3
}

class ResponseCacheViewController: UIViewController {
    @IBOutlet private var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Server", forSegmentAt: 0)
            segmentedControl.setTitle("Cache", forSegmentAt: 1)
            segmentedControl.setTitle("DiskCache", forSegmentAt: 2)
            segmentedControl.setTitle("MemoryCache", forSegmentAt: 3)
        }
    }

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    private var responseCacheType: ResponseCacheType = .server {
        didSet {
            request()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        request()
    }

    @IBAction private func segmentAction(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if let type = ResponseCacheType(rawValue: index) {
            responseCacheType = type
        }
    }

    @IBAction private func clearMemoryCacheAction(_ sender: UIButton) {
        let provider = SYMoyaProvider<HTTPBinDynamicData>()
        provider.clearMemoryCache()
        againFetchIfNeeded(responseCacheType: .memoryCache, provider: provider)
    }

    @IBAction private func clearDiskCacheAction(_ sender: UIButton) {
        let provider = SYMoyaProvider<HTTPBinDynamicData>()
        provider.clearDiskCache {
            self.againFetchIfNeeded(responseCacheType: .diskCache, provider: provider)
        }
    }

    @IBAction private func clearAllCacheAction(_ sender: UIButton) {
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
        switch responseCacheType {
        case .server:
            provider.responseString(.server, target: .getDelay(delay: 1)) { response in
                switch response.result {
                case let .success(success):
                    self.contentLabel.text = success
                case let .failure(failure):
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
        fetch(cacheFromType: .disk, provider: provider)
    }

    func fetchMemoryCache(provider: SYMoyaProvider<HTTPBinDynamicData>) {
        fetch(cacheFromType: .memory, provider: provider)
    }

    func fetchCache(provider: SYMoyaProvider<HTTPBinDynamicData>) {
        fetch(cacheFromType: .memoryOrDisk, provider: provider)
    }

    func fetch(cacheFromType: NetworkCacheFromType, provider: SYMoyaProvider<HTTPBinDynamicData>) {
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            provider.responseStringFromCache(cacheFromType, target: .getDelay(delay: 1)) { response in
                switch response.result {
                case let .success(success):
                    self.contentLabel.text = success
                case let .failure(failure):
                    self.contentLabel.text = failure.localizedDescription
                }
                self.resetState()
            }
        })
    }
}
