//
//  UIPageTabBar.swift
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

public enum UIPageTabBarPosition {
    case top, bottom
}

open class UIPageTabBar: UIView {
    
    // MARK: - Public

    open weak var controller: UIPageTabBarController? {
        didSet {
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
            setNeedsDisplay()
            DispatchQueue.main.async {
                self.updateCurrentIndex(self.currentIndex, shouldScroll: false)
            }
        }
    }
    
    open var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UIPageTabBarItem.self, forCellWithReuseIdentifier: UIPageTabBarItem.cellIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        return collectionView
    }()
    
    open var currentBarViewHeight: CGFloat {
        get {
            return currentBarViewHeightConstraint?.constant ?? 0
        }
        set {
            layoutIfNeeded()
            UIView.animate(withDuration: 0.1) {
                self.currentBarViewHeightConstraint?.constant = newValue
                self.layoutIfNeeded()
            }
            collectionView.reloadData()
        }
    }
    
    open var currentIndex: Int {
        get {
            return _currentIndex
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        collectionView.reloadData()
    }
    
    // MARK: - Private
    
    internal var tabItemPressedBlock: ((_ index: Int, _ direction: UIPageViewControllerNavigationDirection) -> Void)?
    internal var currentBarView = UIView()
    
    private var _currentIndex: Int = 0
    private var numberOfTabs: Int {
        get {
            return controller?.viewControllers.count ?? 0
        }
    }
    private var shouldScrollToItem: Bool = false
    private var pageTabItemsWidth: CGFloat {
        get {
            return controller?.tabBarItemWidth ?? 0.0
        }
    }
    private var collectionViewContentOffsetX: CGFloat = 0.0
    private var currentBarViewWidth: CGFloat = 0.0
    private var currentBarViewLeftConstraint: NSLayoutConstraint?

    private var tabBarPosition: UIPageTabBarPosition = .top
    private var previousIndex: Int = 0
    
    
    private var currentBarViewWidthConstraint: NSLayoutConstraint? {
        get {
            return currentBarView.constraint(withIdentifier: "width")
        }
    }
    private var currentBarViewHeightConstraint: NSLayoutConstraint? {
        get {
            return currentBarView.constraint(withIdentifier: "height")
        }
    }
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(frame: .zero)
        
        currentBarView.backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.constrainToSuperview()
        collectionView.addSubview(currentBarView)
        
        
        let left = NSLayoutConstraint(item: currentBarView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: collectionView,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        collectionView.addConstraint(left)
        currentBarViewLeftConstraint = left
        currentBarView.addConstraints(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 2)
    }
    
    /**
     Called when you rotate the device, moves the contentOffset of collectionView
     
     - parameter index: Next Index
     - parameter contentOffsetX: contentOffset.x of scrollView of isInfinityTabPageViewController
     */
    open func scrollCurrentBarView(_ index: Int, contentOffsetX: CGFloat) {
        
        if collectionViewContentOffsetX == 0.0 {
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }
        
        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let nextIndexPath = IndexPath(item: index, section: 0)
        if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? UIPageTabBarItem, let nextCell = collectionView.cellForItem(at: nextIndexPath) as? UIPageTabBarItem {
            
            if currentBarViewWidth == 0.0 {
                currentBarViewWidth = currentCell.frame.width
            }
            
            let scrollRate = contentOffsetX / frame.width
                        
            let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
            if scrollRate > 0 {
                currentBarViewLeftConstraint?.constant = currentCell.frame.minX + scrollRate * currentCell.frame.width
            } else {
                currentBarViewLeftConstraint?.constant = currentCell.frame.minX + nextCell.frame.width * scrollRate
            }
            currentBarViewWidthConstraint?.constant = currentBarViewWidth + width
        }
    }
    
    /**
     Center the current cell after page swipe
     */
    open func scrollToHorizontalCenter() {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionViewContentOffsetX = collectionView.contentOffset.x
    }
    
    /**
     Called in after the transition is complete pages in isInfinityTabPageViewController in the process of updating the current
     
     - parameter index: Next Index
     */
    open func updateCurrentIndex(_ index: Int, shouldScroll: Bool) {
        
        guard let viewControllerCount = controller?.viewControllers.count, index >= 0 && index < viewControllerCount else {
            return
        }
        
        deselectVisibleCells()
        
        _currentIndex = index
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: shouldScroll)
    }
    
    /**
     Make the tapped cell the current
     
     - parameter index: Next IndexPath
     */
    private func updateCurrentIndexForTap(_ index: Int) {
        deselectVisibleCells()
        
        _currentIndex = index
        let indexPath = IndexPath(item: index, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: true)
    }
    
    /**
     Move the collectionView to IndexPath of Current
     
     - parameter indexPath: Next IndexPath
     - parameter animated: true when you tap to move the isInfinityUIPageTabBarItemItem
     - parameter shouldScroll:
     */
    internal func moveCurrentBarView(_ indexPath: IndexPath, animated: Bool, shouldScroll: Bool) {
        if shouldScroll {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            layoutIfNeeded()
            collectionViewContentOffsetX = 0.0
            currentBarViewWidth = 0.0
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? UIPageTabBarItem {
            currentBarView.isHidden = false
            if animated && shouldScroll {
                cell.isCurrent = true
            }
            currentBarViewWidthConstraint?.constant = cell.frame.width
            currentBarViewLeftConstraint?.constant = cell.frame.origin.x
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                if !animated && shouldScroll {
                    cell.isCurrent = true
                }
                
                self.updateCollectionViewUserInteractionEnabled(true)
            })
        }
        previousIndex = currentIndex
    }
    
    /**
     Touch event control of collectionView
     
     - parameter userInteractionEnabled: Bool
     */
    func updateCollectionViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
        collectionView.isUserInteractionEnabled = userInteractionEnabled
    }
    
    /**
     Update all of the cells in the display to the unselected state
     */
    private func deselectVisibleCells() {
        collectionView.visibleCells.flatMap { $0 as? UIPageTabBarItem }.forEach { $0.isCurrent = false }
    }
}

extension UIPageTabBar: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfTabs
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UIPageTabBarItem.cellIdentifier, for: indexPath) as! UIPageTabBarItem
        cell.titleLabel.text = controller?.viewControllers[indexPath.row].title
        cell.isCurrent = indexPath.item == (currentIndex % numberOfTabs)
        cell.iconView.image = controller?.viewControllers[indexPath.row].tabBarItem.image
        cell.tintColor = tintColor
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // FIXME: Tabs are not displayed when processing is performed during introduction display
        if let cell = cell as? UIPageTabBarItem {
            let fixedIndex = indexPath.item
            cell.isCurrent = fixedIndex == (currentIndex % numberOfTabs)
        }
    }
}

extension UIPageTabBar: UICollectionViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Accept the touch event because animation is complete
        updateCollectionViewUserInteractionEnabled(true)
        
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        if shouldScrollToItem {
            // After the moved so as not to sense of incongruity, to adjust the contentOffset at the currentIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            shouldScrollToItem = false
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fixedIndex = indexPath.item
        let isCurrent = fixedIndex == (currentIndex % numberOfTabs)
        var direction: UIPageViewControllerNavigationDirection = .forward
        if indexPath.item < currentIndex {
            direction = .reverse
        }
        self.tabItemPressedBlock?(fixedIndex, direction)
        
        if !isCurrent {
            // Not accept touch events to scroll the animation is finished
            self.updateCollectionViewUserInteractionEnabled(false)
        }
        self.updateCurrentIndexForTap(indexPath.item)
    }
}

extension UIPageTabBar: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = pageTabItemsWidth == 0 ? (frame.width / CGFloat(numberOfTabs)) : pageTabItemsWidth
        let size = CGSize(width: width, height: frame.height)
        return size
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
