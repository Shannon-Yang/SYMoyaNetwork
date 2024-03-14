//
//  ResponseCacheViewController.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/1.
//

import UIKit

class ResponseCacheViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Normal", forSegmentAt: 0)
            segmentedControl.setTitle("Combine", forSegmentAt: 1)
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
