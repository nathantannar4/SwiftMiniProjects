//
//  UITagDeleteButton.swift
//  UITagInputView
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
//  Created by Nathan Tannar on 8/16/17.
//

import UIKit

open class UITagDeleteButton: UIButton {
    
    open weak var tagButton: UITagButton?
    
    private var top: CAShapeLayer = CAShapeLayer()
    private var bottom: CAShapeLayer = CAShapeLayer()
    private var originalTintColor: UIColor? = .white
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open override func draw(_ rect: CGRect) {
        
        UIColor.white.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false)
        
        let topPath = UIBezierPath()
        topPath.move(to: CGPoint(x: 5,y: 5))
        topPath.addLine(to: CGPoint(x: 25,y: 25))
        topPath.stroke()
        top.path = topPath.cgPath
        layer.addSublayer(top)
        
        let bottomPath = UIBezierPath()
        bottomPath.move(to: CGPoint(x: 5,y: 25))
        bottomPath.addLine(to: CGPoint(x: 25,y: 5))
        bottomPath.stroke()
        bottom.path = bottomPath.cgPath
        layer.addSublayer(bottom)
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        top.fillColor = tintColor.cgColor
        bottom.fillColor = tintColor.cgColor
    }
    
    // MARK: - Methods
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        originalTintColor = tintColor
        tintColor = tintColor.withAlphaComponent(0.3)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        tintColor = originalTintColor
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        tintColor = originalTintColor
    }
}

