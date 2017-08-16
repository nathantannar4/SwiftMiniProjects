//
//  UITagInputView.swift
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
//  Created by Nathan Tannar on 6/11/17.
//  Adapted from https://github.com/ElaWorkshop/TagListView
//

import Foundation
import UIKit

@objc public protocol UITagInputViewDelegate {
    @objc optional func tagInputView(_ tagInputView: UITagInputView, didAdd tag: UITagButton) -> Void
    @objc optional func tagInputView(_ tagInputView: UITagInputView, didTapDeleteButtonOf tag: UITagButton) -> Void
    @objc optional func tagInputView(_ tagInputView: UITagInputView, didTouch tag: UITagButton) -> Void
}

open class UITagInputView: UIScrollView {
    
    open dynamic var textColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagButtons {
                tagView.textColor = textColor
            }
        }
    }
    
    open dynamic var selectedTextColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagButtons {
                tagView.selectedTextColor = selectedTextColor
            }
        }
    }
    
    open dynamic var tagHighlightedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagButtons {
                tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
            }
        }
    }
    
    open dynamic var cornerRadius: CGFloat = 5 {
        didSet {
            for tagView in tagButtons {
                tagView.cornerRadius = cornerRadius
            }
        }
    }
    open dynamic var borderWidth: CGFloat = 0 {
        didSet {
            for tagView in tagButtons {
                tagView.borderWidth = borderWidth
            }
        }
    }
    
    open dynamic var borderColor: UIColor? {
        didSet {
            for tagView in tagButtons {
                tagView.borderColor = borderColor
            }
        }
    }
    
    open dynamic var selectedBorderColor: UIColor? {
        didSet {
            for tagView in tagButtons {
                tagView.selectedBorderColor = selectedBorderColor
            }
        }
    }
    
    open dynamic var paddingY: CGFloat = 5 {
        didSet {
            for tagView in tagButtons {
                tagView.paddingY = paddingY
            }
            rearrangeViews()
        }
    }
    open dynamic var paddingX: CGFloat = 10 {
        didSet {
            for tagView in tagButtons {
                tagView.paddingX = paddingX
            }
            rearrangeViews()
        }
    }
    open dynamic var marginY: CGFloat = 5 {
        didSet {
            rearrangeViews()
        }
    }
    open dynamic var marginX: CGFloat = 5 {
        didSet {
            rearrangeViews()
        }
    }
    
    public enum Alignment: Int {
        case left
        case center
        case right
    }
    
    open var alignment: Alignment = .left {
        didSet {
            rearrangeViews()
        }
    }
    open dynamic var shadowColor: UIColor = UIColor.white {
        didSet {
            rearrangeViews()
        }
    }
    open dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            rearrangeViews()
        }
    }
    open dynamic var shadowOffset: CGSize = CGSize.zero {
        didSet {
            rearrangeViews()
        }
    }
    open dynamic var shadowOpacity: Float = 0 {
        didSet {
            rearrangeViews()
        }
    }
    
    open dynamic var enableDeleteButton: Bool = true {
        didSet {
            for tagView in tagButtons {
                tagView.enableDeleteButton = enableDeleteButton
            }
            rearrangeViews()
        }
    }
    
    open dynamic var textFont: UIFont = UIFont.preferredFont(forTextStyle: .body) {
        didSet {
            for tagView in tagButtons {
                tagView.textFont = textFont
            }
            rearrangeViews()
        }
    }
    
    open var tagDelegate: UITagInputViewDelegate?
    
    open private(set) var tagButtons: [UITagButton] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        rearrangeViews()
    }
    
    private func rearrangeViews() {
        let views = tagButtons as [UIView] + tagBackgroundViews + rowViews
        for view in views {
            view.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)
        
        var currentRow = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, tagView) in tagButtons.enumerated() {
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            
            if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > frame.width {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)
            }
            
            let tagBackgroundView = tagBackgroundViews[index]
            tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            tagBackgroundView.frame.size = tagView.bounds.size
            tagBackgroundView.layer.shadowColor = shadowColor.cgColor
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).cgPath
            tagBackgroundView.layer.shadowOffset = shadowOffset
            tagBackgroundView.layer.shadowOpacity = shadowOpacity
            tagBackgroundView.layer.shadowRadius = shadowRadius
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)
            
            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX
            
            switch alignment {
            case .left:
                currentRowView.frame.origin.x = 0
            case .center:
                currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
            case .right:
                currentRowView.frame.origin.x = frame.width - (currentRowWidth - marginX)
            }
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
        }
        rows = currentRow
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Manage tags
    
    override open var intrinsicContentSize: CGSize {
        var height = CGFloat(rows) * (tagViewHeight + marginY)
        if rows > 0 {
            height -= marginY
        }
        let size = CGSize(width: frame.width, height: height)
        contentSize = size
        
        return size
    }
    
    open func createNewTagView(_ title: String) -> UITagButton {
        let tagView = UITagButton(title: title)
        
        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tintColor
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tintColor.withAlphaComponent(0.3)
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.enableDeleteButton = enableDeleteButton
        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        tagView.deleteButton.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
        
        // On long press, deselect all tags except this one
        tagView.onLongPress = { [unowned self] this in
            for tag in self.tagButtons {
                tag.isSelected = (tag == this)
            }
        }
        
        return tagView
    }
    
    @discardableResult
    open func addTag(_ title: String) -> UITagButton {
        return addTagButton(createNewTagView(title))
    }
    
    @discardableResult
    open func addTags(_ titles: [String]) -> [UITagButton] {
        var tagButtons: [UITagButton] = []
        for title in titles {
            tagButtons.append(createNewTagView(title))
        }
        return addTagButtons(tagButtons)
    }
    
    @discardableResult
    open func addTagButtons(_ tagButtons: [UITagButton]) -> [UITagButton] {
        for tagView in tagButtons {
            self.tagButtons.append(tagView)
            tagBackgroundViews.append(UIView(frame: tagView.bounds))
        }
        rearrangeViews()
        return tagButtons
    }
    
    @discardableResult
    open func insertTag(_ title: String, at index: Int) -> UITagButton {
        return insertTagView(createNewTagView(title), at: index)
    }
    
    @discardableResult
    open func addTagButton(_ tagButton: UITagButton) -> UITagButton {
        tagButtons.append(tagButton)
        tagBackgroundViews.append(UIView(frame: tagButton.bounds))
        rearrangeViews()
        tagDelegate?.tagInputView?(self, didAdd: tagButton)
        return tagButton
    }
    
    @discardableResult
    open func insertTagView(_ tagView: UITagButton, at index: Int) -> UITagButton {
        tagButtons.insert(tagView, at: index)
        tagBackgroundViews.insert(UIView(frame: tagView.bounds), at: index)
        rearrangeViews()
        
        return tagView
    }
    
    open func setTitle(_ title: String, at index: Int) {
        tagButtons[index].titleLabel?.text = title
    }
    
    open func removeTag(_ title: String) {
        // loop the array in reversed order to remove items during loop
        for index in stride(from: (tagButtons.count - 1), through: 0, by: -1) {
            let tagButton = tagButtons[index]
            if tagButton.currentTitle == title {
                removeTagButton(tagButton)
            }
        }
    }
    
    open func removeTagButton(_ tagButton: UITagButton) {
        tagButton.removeFromSuperview()
        if let index = tagButtons.index(of: tagButton) {
            tagButtons.remove(at: index)
            tagBackgroundViews.remove(at: index)
        }
        
        rearrangeViews()
    }
    
    open func removeAllTags() {
        let views = tagButtons as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagButtons = []
        tagBackgroundViews = []
        rearrangeViews()
    }
    
    open func selectedTags() -> [UITagButton] {
        return tagButtons.filter() { $0.isSelected == true }
    }
    
    // MARK: - Events
    
    open func tagPressed(_ sender: UITagButton) {
        sender.onTap?(sender)
        tagDelegate?.tagInputView?(self, didTouch: sender)
    }
    
    open func deleteButtonPressed(_ closeButton: UITagDeleteButton) {
        if let tagButton = closeButton.tagButton {
            tagDelegate?.tagInputView?(self, didTapDeleteButtonOf: tagButton)
        }
    }
}
