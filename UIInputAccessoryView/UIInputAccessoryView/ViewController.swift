//
//  ViewController.swift
//  UIInputAccessoryView
//
//  Created by Nathan Tannar on 8/13/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextInputAccessoryViewDelegate, UITextViewDelegate {
    
    let inputBar = UITextInputAccessoryView()
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputBar.delegate = self
//        inputBar.isTranslucent = true
        inputBar.textView.delegate = self
        inputBar.tintColor = .red
        inputBar.alwaysHideAccessoryButton = true
        inputBar.alwaysHideAccessoryButton = false
    }

    func textInput(_ textInput: UITextInputAccessoryView, contentSizeDidChangeTo size: CGSize) {
        
    }
    
    func textInput(_ textInput: UITextInputAccessoryView, textDidChangeTo text: String) {
        print(text)
    }
}

