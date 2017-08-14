//
//  ViewController.swift
//  UIWebViewController
//
//  Created by Nathan Tannar on 8/8/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let urls = ["https://www.google.ca", "www.apple.ca", "youtube.ca", "swift open-source"]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = urls[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIWebViewController()
        let urlString = vc.makeValidURL(with: urls[indexPath.row])
        vc.url = URL(string: urlString)
        vc.loadRequest(forURL: vc.url)
        vc.isUITranslucent = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

