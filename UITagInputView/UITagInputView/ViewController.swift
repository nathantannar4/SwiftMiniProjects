//
//  ViewController.swift
//  UITagInputView
//
//  Created by Nathan Tannar on 8/15/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITagInputViewDelegate, UITextInputAccessoryViewDelegate {

    let tagInputView = UITagInputView()
    let inputBar = UITextInputAccessoryView()
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(tagInputView)
        inputBar.delegate = self
        tagInputView.backgroundColor = UIColor.groupTableViewBackground
        tagInputView.layer.borderColor = UIColor.lightGray.cgColor
        tagInputView.layer.borderWidth = 1
        tagInputView.tagDelegate = self
        tagInputView.translatesAutoresizingMaskIntoConstraints = false
        tagInputView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        tagInputView.topAnchor.constraint(equalTo: view.topAnchor, constant: 28).isActive = true
        tagInputView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        tagInputView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }

    func textInput(_ textInput: UITextInputAccessoryView, didPressSendButtonWith text: String) {
        tagInputView.addTag(text)
        textInput.textView.text = String()
    }
    
    func tagInputView(_ tagInputView: UITagInputView, didTouch tag: UITagButton) {
        print(tag)
    }
    
    func tagInputView(_ tagInputView: UITagInputView, didAdd tag: UITagButton) {
        print("Will add tag: \(tag)")
    }
    
    func tagInputView(_ tagInputView: UITagInputView, didTapDeleteButtonOf tag: UITagButton) {
        print("Will delete tag: \(tag)")
        tagInputView.removeTagButton(tag)
    }
}

