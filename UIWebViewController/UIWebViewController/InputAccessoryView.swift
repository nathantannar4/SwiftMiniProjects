//
//  NTInputAccessoryView.swift
//  UIWebViewController
//
//  Created by Nathan Tannar on 5/22/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

open class InputAccessoryView: UIView {
    
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
            NotificationCenter.default.addObserver(self, selector: #selector(InputAccessoryView.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(InputAccessoryView.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(InputAccessoryView.keyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
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
    
    fileprivate var keyboardIsHidden: Bool = true
    
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


