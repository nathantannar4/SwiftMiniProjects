//
//  ViewController.swift
//  UIPageTabBarController
//
//  Created by Nathan Tannar on 8/11/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var addButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Add ViewController", for: .normal)
        button.addTarget(self, action: #selector(ViewController.addVC), for: .touchUpInside)
        button.backgroundColor = .black
        return button
    }()
    
    lazy var deleteButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Delete ViewController", for: .normal)
        button.addTarget(self, action: #selector(ViewController.deleteVC), for: .touchUpInside)
        button.backgroundColor = .black
        return button
    }()
    
    func addVC() {
        let newVC = ViewController()
        newVC.title =  "New VC"
        DispatchQueue.main.async {
            self.pageTabViewController?.insertViewController(newVC, atIndex: self.pageTabViewController!.viewControllers.count - 1)
        }
    }
    
    func deleteVC() {
        guard let index = pageTabViewController?.currentIndex else {
            return
        }
        print(index)
        DispatchQueue.main.async {
            self.pageTabViewController?.removeViewController(atIndex: self.pageTabViewController!.currentIndex)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(addButton)
        view.addSubview(deleteButton)
        
        addButton.constrainCenterToSuperview()
        deleteButton.addConstraints(addButton.bottomAnchor, left: addButton.leftAnchor, bottom: nil, right: addButton.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
