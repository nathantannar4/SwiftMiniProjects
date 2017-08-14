//
//  FacebookInputBar.swift
//  UITextInputAccessoryView
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 8/13/17.
//

import UIKit

class FacebookInputBar: UITextInputAccessoryView {
    
    open lazy var accessoryButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(named: "icons8-forward_filled"), for: .normal)
        button.backgroundColor = .lightBlue
        button.layer.cornerRadius = 15
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(didPressAccessoryButton(_:)), for: .touchUpInside)
        button.autoresizingMask = .flexibleHeight
        return button
    }()
    
    // this could be any type of view. Used a toolbar for simplicity but a stack view would also work well for keeping items sized the same
    open let abaView: UIToolbar = { // accessoryButtonActionsView
        let view = UIToolbar()
        view.isTranslucent = false
        view.barTintColor = .white
        view.setShadowImage(UIImage(), forToolbarPosition: .any)
        view.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
        let items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.bookmarks, target: nil, action: nil)
        ]
        
        view.items = items
        return view
    }()
    
    private var abaViewWidthContraint: NSLayoutConstraint?
    
    func didPressAccessoryButton(_ sender: AnyObject?) {
        guard let constant = abaViewWidthContraint?.constant else {
            return
        }
//        let placeholderTextColor = textView.placeholderTextColor
//        textView.placeholderTextColor = .clear
        layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            if constant == 0 {
                self.abaViewWidthContraint?.constant = CGFloat(self.abaView.items?.count ?? 0) * 44
                self.accessoryButton.setImage(UIImage(named: "icons8-back_filled"), for: .normal)
            } else {
                self.abaViewWidthContraint?.constant = 0
                self.accessoryButton.setImage(UIImage(named: "icons8-forward_filled"), for: .normal)
            }
            self.layoutIfNeeded()
        }) { _ in
//            self.textView.placeholderTextColor = placeholderTextColor
            self.textView.setNeedsDisplay()
        }
    }
    
    override func setupSubviews() {
        addSubview(abaView)
        super.setupSubviews()
        addSubview(accessoryButton)
    }
    
    override func setupConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        abaView.translatesAutoresizingMaskIntoConstraints = false
        abaViewWidthContraint = abaView.widthAnchor.constraint(equalToConstant: 0)
        abaViewWidthContraint?.isActive = true
        _ = [
            abaView.heightAnchor.constraint(equalToConstant: 44),
            abaView.leftAnchor.constraint(equalTo: accessoryButton.rightAnchor),
            abaView.bottomAnchor.constraint(equalTo: bottomAnchor),
            accessoryButton.leftAnchor.constraint(equalTo: leftAnchor, constant: padding / 2),
            accessoryButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            accessoryButton.widthAnchor.constraint(equalToConstant: 30),
            accessoryButton.heightAnchor.constraint(equalToConstant: 30),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: padding / 2),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding / 2),
            textView.leftAnchor.constraint(equalTo: abaView.rightAnchor, constant: padding / 2),
            textView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -padding / 2),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding / 2),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 44)
        ].map { $0.isActive = true }
    }
}
