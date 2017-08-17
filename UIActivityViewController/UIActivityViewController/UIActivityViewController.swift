//
//  UIActivityViewController.swift
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

public class UIActivityViewController: UIViewController {
    
    // MARK: - Properties
    
    public var activityView = UIActivityView()
    public var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.backgroundColor = .white
        label.layer.cornerRadius = 16
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        label.textAlignment = .center
        return label
    }()
    
    open var statusText: String? {
        get {
            return statusLabel.text
        }
        set {
            statusLabel.text = newValue
        }
    }
    
    private var timer: Timer?
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(blurStyle: .dark, operation: nil, timoutAfter: 5)
    }
    
    required public init(blurStyle: UIBlurEffectStyle, operation: (()->Void)? = nil, timoutAfter: Double = 30) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = .clear
        setupBlur(blurStyle)
        setupActivity()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlur(_ blurStyle: UIBlurEffectStyle) {
        
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        _ = [
            blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ].map { $0.isActive = true }
    }
    
    private func setupActivity() {
        view.addSubview(activityView)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        _ = [
            activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityView.widthAnchor.constraint(equalToConstant: 100),
            activityView.heightAnchor.constraint(equalToConstant: 100)
            ].map { $0.isActive = true }
        view.addSubview(statusLabel)
        _ = [
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            statusLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            statusLabel.heightAnchor.constraint(equalToConstant: 40),
            statusLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ].map { $0.isActive = true }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        activityView.startAnimating()
    }
    
    // MARK: - Methods
    
    func handleTimer(_ timer: Timer) {
        
    }
    
    public func invalidate() {
        
    }
}
