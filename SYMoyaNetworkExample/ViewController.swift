//
//  ViewController.swift
//  SYMoyaNetwork-Example
//
//  Created by ShannonYang on 2021/9/16.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var data = ["Basic Response","HandyJSON Response","MJExtension Response","ObjectMapper Response","SwiftyJSON Response","Batch Response","Batch Response"]

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


//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        let item = self.data[indexPath.row]
        cell.textLabel?.text = item
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let re = ResponseViewController() 
        self.navigationController?.pushViewController(re, animated: true)
    }
    
}
