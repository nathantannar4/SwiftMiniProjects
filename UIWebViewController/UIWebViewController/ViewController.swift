//
//  ViewController.swift
//  UIWebViewController
//
//  Created by Nathan Tannar on 8/8/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let urls = ["https://google.ca", "https://apple.ca"]

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
        let url = URL(string: urls[indexPath.row])!
        let vc = UIWebViewController(url: url)
        vc.isUITranslucent = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

