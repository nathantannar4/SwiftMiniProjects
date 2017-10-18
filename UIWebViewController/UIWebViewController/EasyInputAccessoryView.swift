//
//  EasyInputAccessoryView.swift
//  UIWebViewController
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
//  Created by Nathan Tannar on 8/10/17.
//

import UIKit

open class EasyInputAccessoryView: UIView {
    
    open var heightConstant: CGFloat = 44 {
        didSet {
            if controller != nil {
                layoutConstraints?[3].constant = heightConstant
                controller?.view.layoutIfNeeded()
            }
        }
    }
    
    open var controller: UIViewController? {
        didSet {
            guard let vc = controller else {
                return
            }
            NotificationCenter.default.addObserver(self, selector: #selector(EasyInputAccessoryView.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(EasyInputAccessoryView.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(EasyInputAccessoryView.keyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
            vc.view.addSubview(self)
            
            translatesAutoresizingMaskIntoConstraints = false
            layoutConstraints = [
                leftAnchor.constraint(equalTo: vc.view.leftAnchor),
                bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
                rightAnchor.constraint(equalTo: vc.view.rightAnchor),
                heightAnchor.constraint(equalToConstant: heightConstant)
            ]
            _ = layoutConstraints?.map{ $0.isActive = true }
        }
    }
    
    open var layoutConstraints: [NSLayoutConstraint]?
    
    private var keyboardIsHidden: Bool = true
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - De-Initialization

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Observer
    
    open func keyboardDidChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, !keyboardIsHidden, let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            guard let constant = self.layoutConstraints?[1].constant else {
                return
            }
            if keyboardSize.height < constant {
                return
            }
            
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                self.layoutConstraints?[1].constant = -keyboardSize.height
                self.controller?.view.layoutIfNeeded()
            })
        }
    }
    
    open func keyboardWillShow(notification: NSNotification) {
        keyboardIsHidden = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                self.layoutConstraints?[1].constant = -keyboardSize.height
                self.controller?.view.layoutIfNeeded()
            })
        }
    }
    
    open func keyboardWillHide(notification: NSNotification) {
        keyboardIsHidden = true
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                self.layoutConstraints?[1].constant = 0
                self.controller?.view.layoutIfNeeded()
            })
        }
    }
}


