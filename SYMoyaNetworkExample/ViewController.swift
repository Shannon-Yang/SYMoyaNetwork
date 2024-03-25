//
//  ViewController.swift
//  SYMoyaNetwork-Example
//
//  Created by Shannon Yang on 2021/9/16.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

enum ResponseType: String, CaseIterable {
    case string = "String Response"
    case json = "JSON Response"
    case image = "Image Response"
    case decodable = "Decodable Response"
    case swiftyJSON = "SwiftyJSON Response"
    case handyJSON = "HandyJSON Response"
    case objectMapper = "ObjectMapper Response"
    case batch = "Batch Response"
    case chain = "Chain Response"
    case cache = "Reuqest Cache"
}

#if os(iOS)
import UIKit
class ViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    
    fileprivate var data = ResponseType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.title = "Example"
    }
}

// MARK: - Private

private extension ViewController {
    func registerCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        let item = self.data[indexPath.row]
        cell.textLabel?.text = item.rawValue
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = self.data[indexPath.row]
        switch type {
        case .batch:
            let re = BatchResponseViewController()
            self.navigationController?.pushViewController(re, animated: true)
        case .chain:
            let re = ChainResponseViewController()
            self.navigationController?.pushViewController(re, animated: true)
        case .cache:
            let re = ResponseCacheViewController()
            self.navigationController?.pushViewController(re, animated: true)
        default:
            let re = ResponseViewController(responseType: type)
            self.navigationController?.pushViewController(re, animated: true)
        }
    }
}
#endif
