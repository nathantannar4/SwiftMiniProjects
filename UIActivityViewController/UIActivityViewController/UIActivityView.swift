//
//  NTActivityView.swift
//  UIActivityViewController
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

open class UIActivityView: UIView {
    
    open var circleLayers = [CAShapeLayer()]
    
    open var isAnimating: Bool {
        return animating
    }
    
    private var animating: Bool = false
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 16
        
        for layer in circleLayers {
            layer.lineCap = "round"
            layer.lineWidth = 4
            layer.fillColor = nil
            layer.strokeColor = UIColor.black.cgColor
            self.layer.addSublayer(layer)
            layer.isHidden = true
        }
        tintColorDidChange()
    }
    
    // MARK: - Standard Methods
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        var radius = min(bounds.width, bounds.height) / 2 - 14
        let startAngle = CGFloat(-Double.pi)
        let endAngle = startAngle + CGFloat(Double.pi * 2)
        
        for layer in circleLayers {
            let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            layer.position = center
            layer.path = path.cgPath
            radius -= bounds.midX / 3
        }
    }
    
    override open func tintColorDidChange() {
        super.tintColorDidChange()
        for layer in circleLayers {
            layer.strokeColor = tintColor.cgColor
        }
    }

    // MARK: - Animation Methods
    
    open func startAnimating() {
        if !animating {
            for (index, layer) in circleLayers.enumerated() {
                layer.isHidden = false
                let multiplier = index % 2 == 0 ? 1 : -1
                layer.add(strokeEndAnimation(multiplyer: multiplier), forKey: "strokeEnd")
                layer.add(strokeStartAnimation(multiplyer: multiplier), forKey: "strokeStart")
                layer.add(strokeRotateAnimation(multiplyer: multiplier), forKey: "rotation")
            }
            animating = true
        }
    }
    
    open func stopAnimating() {
        if animating {
            for layer in circleLayers {
                layer.isHidden = true
                layer.removeAnimation(forKey: "strokeEnd")
                layer.removeAnimation(forKey: "strokeStart")
                layer.removeAnimation(forKey: "rotation")
            }
            animating = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func strokeEndAnimation(multiplyer: Int) -> CAAnimationGroup {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.byValue = 1
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let group = CAAnimationGroup()
        group.duration = 2.5
        group.repeatCount = MAXFLOAT
        group.animations = [animation]
        
        return group
    }
    
    private func strokeStartAnimation(multiplyer: Int) -> CAAnimationGroup {
        
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let group = CAAnimationGroup()
        group.duration = 2.5
        group.repeatCount = MAXFLOAT
        group.animations = [animation]
        
        return group
    }
    
    private func strokeRotateAnimation(multiplyer: Int) -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2 * Double(multiplyer)
        animation.duration = 4
        animation.repeatCount = MAXFLOAT
        animation.speed = 1.4
        return animation
    }
}
