//
//  UIPageTabBarItem.swift
//  UIKitExtension
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
//  Created by Nathan Tannar on 7/10/17.
//

import UIKit

open class UIPageTabBarItem: UICollectionViewCell {
  
    open var isCurrent: Bool = false {
        didSet {
            if isCurrent {
                titleLabel.textColor = tintColor
                titleLabel.isEnabled = true
                iconView.tintColor = tintColor
            } else {
                titleLabel.isEnabled = false
                iconView.tintColor = UIColor.gray
            }
        }
    }
    
    open static var cellIdentifier: String {
        get {
            return "UIPageTabBarItem"
        }
    }
    
    open var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.isUserInteractionEnabled = false
        return label
    }()
    
    open var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        iconView.tintColor = tintColor
    }
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(titleLabel)
        addSubview(iconView)
        titleLabel.constrainToSuperview()
        iconView.addConstraints(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 3, leftConstant: 3, bottomConstant: 3, rightConstant: 3, widthConstant: 0, heightConstant: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

