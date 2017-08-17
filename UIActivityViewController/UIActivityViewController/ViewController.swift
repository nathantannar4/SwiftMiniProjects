//
//  ViewController.swift
//  UIActivityViewController
//
//  Created by Nathan Tannar on 8/16/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let button = UIButton(frame: CGRect(x: view.frame.width / 2 - 50, y: view.frame.maxY * 2 / 3, width: 100, height: 40))
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        button.setTitle("Activate", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8
        view.addSubview(button)
        
        let textView = UITextView(frame: CGRect(x: 20, y: 30, width: view.frame.width - 40, height: 300))
        textView.text = Lorem.paragraphs(nbParagraphs: 4)
        view.addSubview(textView)
    }

    func handleButton() {
        let vc = UIActivityViewController(blurStyle: .light, operation: {
            
        }, timoutAfter: 3)
        present(vc, animated: false, completion: nil)
    }
}

