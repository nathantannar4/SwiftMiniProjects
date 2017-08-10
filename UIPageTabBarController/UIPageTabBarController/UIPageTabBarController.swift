//
//  UIPageTabBarController.swift
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

public extension UIViewController {
    var pageTabViewController: UIPageTabBarController? {
        var parentViewController = parent
        while parentViewController != nil {
            if let view = parentViewController as? UIPageTabBarController {
                return view
            }
            parentViewController = parentViewController!.parent
        }
        print("View controller did not have a UIPageTabBarController as a parent")
        return nil
    }
}

open class UIPageTabBarController: UIViewController {
    
    // MARK: - Public
    
    /// Retuns the current index of the presented view controller or -1 if there were no view controllers
    public var currentIndex: Int {
        get {
            guard let viewController = pageViewController.viewControllers?.first else {
                return -1
            }
            return viewControllers.index(of: viewController) ?? -1
        }
    }
    
    /// An array holding the viewControllers used by the UIPageViewController
    public var viewControllers: [UIViewController] = []
    
    public lazy var pageViewController: UIPageViewController = { [weak self] in
        
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.backgroundColor = .clear
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let scrollView = pageViewController.view.subviews.flatMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        
        return pageViewController
    }()
    
    public lazy var tabBar: UIPageTabBar = { [weak self] in
        let tabBar = UIPageTabBar()
        tabBar.controller = self
        tabBar.backgroundColor = .white
        tabBar.tabItemPressedBlock = { (index: Int, direction: UIPageViewControllerNavigationDirection) in
            self?.displayControllerWithIndex(index, direction: direction, animated: true)
        }
        return tabBar
    }()
    
    open var currentTabLineHeight: CGFloat = 2 {
        didSet {
            tabBar.currentBarViewHeight = currentTabLineHeight
        }
    }
    
    open var currentTabLineColor: UIColor = .black {
        didSet {
            tabBar.currentBarView.backgroundColor = currentTabLineColor
        }
    }
    
    open var tabBarEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            view.layoutIfNeeded()
            tabBar.collectionView.collectionViewLayout.invalidateLayout()
            UIView.animate(withDuration: 0.1) {
                self.tabBar.constraint(withIdentifier: "top")?.constant = self.tabBarEdgeInsets.top
                self.tabBar.constraint(withIdentifier: "left")?.constant = self.tabBarEdgeInsets.left
                self.tabBar.constraint(withIdentifier: "bottom")?.constant = self.tabBarEdgeInsets.bottom
                self.tabBar.constraint(withIdentifier: "right")?.constant = self.tabBarEdgeInsets.right
                self.view.layoutIfNeeded()
                self.tabBar.layoutIfNeeded()
            }
        }
    }
    
    open var tabBarHeight: CGFloat = 32 {
        didSet {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.1) {
                self.tabBar.constraint(withIdentifier: "height")?.constant = self.tabBarHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    
    open var tabBarItemWidth: CGFloat = 0 {
        didSet {
            tabBar.collectionView.collectionViewLayout.invalidateLayout()
            tabBar.layoutIfNeeded()
        }
    }
    
    open var tabBarPosition: UIPageTabBarPosition = .top
    
    // MARK: - Private
    
    fileprivate var previousIndex: Int = 0
    fileprivate var kDefaultContentXOffset: CGFloat {
        return self.view.bounds.width
    }
    fileprivate var shouldScrollCurrentBar: Bool = true
    fileprivate var isLayedOut: Bool = false
    
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(viewControllers: [UIViewController()])
    }
    
    public required convenience init(viewControllers: [UIViewController]) {
        self.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        setup()
    }
    
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("UIPageTabBarController does not support storyboards")
    }
    
    open func setup() {
        
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        for vc in viewControllers {
            pageViewController.addChildViewController(vc)
            vc.didMove(toParentViewController: pageViewController)
        }
        
        pageViewController.setViewControllers([viewControllers[previousIndex]], direction: .forward, animated: false, completion: nil)
        view.addSubview(tabBar)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isLayedOut { layoutViews() }
    }
    
    open func layoutViews() {
        if tabBarPosition == .top {
            
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            
            tabBar.addConstraints(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: tabBarEdgeInsets.top, leftConstant: tabBarEdgeInsets.left, bottomConstant: tabBarEdgeInsets.bottom, rightConstant: tabBarEdgeInsets.right, widthConstant: 0, heightConstant: tabBarHeight)
            pageViewController.view.addConstraints(tabBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            tabBar.currentBarView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor).isActive = true
        } else {
            
            tabBar.addConstraints(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: tabBarEdgeInsets.top, leftConstant: tabBarEdgeInsets.left, bottomConstant: tabBarEdgeInsets.bottom, rightConstant: tabBarEdgeInsets.right, widthConstant: 0, heightConstant: tabBarHeight)
            pageViewController.view.addConstraints(view.topAnchor, left: view.leftAnchor, bottom: tabBar.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            tabBar.currentBarView.topAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        }
        isLayedOut = true
    }

    open override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        tabBar.collectionView.collectionViewLayout.invalidateLayout()
        tabBar.setNeedsDisplay()
        DispatchQueue.main.async {
            self.tabBar.updateCurrentIndex(self.tabBar.currentIndex, shouldScroll: true)
        }
    }
    
    open func updateTabBarOrigin(hidden: Bool) {
        guard let tabBarTopConstraint = tabBar.constraint(withIdentifier: "top") else { return }
        
        if !hidden && tabBarTopConstraint.constant == tabBarEdgeInsets.top {
            return
        } else if hidden && tabBarTopConstraint.constant != tabBarEdgeInsets.top {
            return
        }
        
        if tabBarPosition == .top {
            tabBarTopConstraint.constant = hidden ? -tabBarHeight : tabBarEdgeInsets.top
        } else {
            tabBarTopConstraint.constant = hidden ? tabBarHeight : tabBarEdgeInsets.top
        }
        UIView.animate(withDuration: 2 * TimeInterval(UINavigationControllerHideShowBarDuration)) {
            self.view.layoutIfNeeded()
        }
    }
}

extension UIPageTabBarController: UIPageViewControllerDataSource {

    // MARK: - UIPageViewControllerDataSource
    
    open func displayControllerWithIndex(_ index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        
        previousIndex = index
        shouldScrollCurrentBar = false
        
        let completion: ((Bool) -> Void) = { [weak self] _ in
            self?.shouldScrollCurrentBar = true
            self?.previousIndex = index
        }
        
        self.pageViewController.setViewControllers([viewControllers[index]], direction: direction, animated: animated, completion: completion)
        
        guard isViewLoaded else { return }
        tabBar.updateCurrentIndex(index, shouldScroll: true)
    }
    
    fileprivate func nextViewController(_ viewController: UIViewController, isAfter: Bool) -> UIViewController? {
        
        guard var index = viewControllers.index(of: viewController) else { return nil }
        if isAfter {
            index += 1
        } else {
            index -= 1
        }
        
        if index >= 0 && index < viewControllers.count {
            return viewControllers[index]
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }
}

extension UIPageTabBarController: UIPageViewControllerDelegate {

    // MARK: - UIPageViewControllerDelegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        shouldScrollCurrentBar = true
        tabBar.scrollToHorizontalCenter()
        
        // Order to prevent the the hit repeatedly during animation
        tabBar.updateCollectionViewUserInteractionEnabled(false)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        tabBar.updateCurrentIndex(currentIndex, shouldScroll: false)
        previousIndex = currentIndex
        tabBar.updateCollectionViewUserInteractionEnabled(true)
    }
}

extension UIPageTabBarController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == kDefaultContentXOffset || !shouldScrollCurrentBar {
            return
        }
        
        var index: Int
        if scrollView.contentOffset.x > kDefaultContentXOffset {
            index = previousIndex + 1
        } else {
            index = previousIndex - 1
        }
        
        if index == viewControllers.count {
            index = 0
        } else if index < 0 {
            index = viewControllers.count - 1
        }
        
        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
        tabBar.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tabBar.updateCurrentIndex(previousIndex, shouldScroll: true)
    }
}
