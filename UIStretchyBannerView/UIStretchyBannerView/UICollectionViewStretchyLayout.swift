//
//  UICollectionViewStretchyLayout.swift
//  UIStretchyBannerView
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

let UIStretchyBannerViewKind = "UIStretchyBannerViewKind"

open class UICollectionViewStretchyLayout: UICollectionViewLayout {
    
    open weak var delegate: UICollectionViewDelegateFlowLayout?
    
    let startingHeaderHeight: CGFloat = 150
    var sectionInset = UIEdgeInsets.zero
    var itemSize = CGSize.zero
    var itemSpacing: CGFloat = 0.0
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    
    override open func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else {
            return
        }
        
        attributes = []
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                if let attribute = layoutAttributesForItem(at: indexPath) {
                    attributes.append(attribute)
                }
            }
        }
        
        if let headerAttribute = layoutAttributesForSupplementaryView(ofKind: UIStretchyBannerViewKind, at: IndexPath(item: 0, section: 0)) {
            attributes.append(headerAttribute)
        }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visibleAttributes = attributes.filter { attribute -> Bool in
            return rect.contains(attribute.frame) || rect.intersects(attribute.frame)
        }
        
        let offset = collectionView?.contentOffset.y ?? 0
        if offset < 0 {
            let extraOffset = fabs(offset)
            
            let stretchyHeader = visibleAttributes.filter { attribute -> Bool in
                return attribute.representedElementKind == UIStretchyBannerViewKind
            }.first
            
            if let collectionHeader = stretchyHeader {
                let headerSize = collectionHeader.frame.size
                collectionHeader.frame.size.height = headerSize.height + extraOffset
                collectionHeader.frame.origin.y = collectionHeader.frame.origin.y - extraOffset
            }
        }
        return visibleAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return nil
        }
        
//        let sectionInset = delegate?.collectionView(collectionView, layout: self, insetForSectionAt: indexPath.section)
        
        var sectionOriginY = startingHeaderHeight + sectionInset.top
        if indexPath.section > 0 {
            let previousSection = indexPath.section - 1
            let lastItem = collectionView.numberOfItems(inSection: previousSection) - 1
            let previousCell = layoutAttributesForItem(at: IndexPath(item: lastItem, section: previousSection))
            sectionOriginY = (previousCell?.frame.maxY ?? 0) + sectionInset.bottom
        }
        
        let itemOriginY = sectionOriginY + CGFloat(indexPath.item) * (itemSize.height + itemSpacing)
        
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.frame = CGRect(x: sectionInset.left, y: itemOriginY, width: itemSize.width, height: itemSize.height)
        return attribute
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UIStretchyBannerViewKind, with: indexPath)
        attribute.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: startingHeaderHeight)
        return attribute
    }
    
    override open var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }
        
        let numberOfSections = collectionView.numberOfSections
        let lastSection = numberOfSections - 1
        let numberOfItems = collectionView.numberOfItems(inSection: lastSection)
        let lastItem = numberOfItems - 1
        
        guard let lastCell = layoutAttributesForItem(at: IndexPath(item: lastItem, section: lastSection)) else {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: lastCell.frame.maxY + sectionInset.bottom)
    }
}
