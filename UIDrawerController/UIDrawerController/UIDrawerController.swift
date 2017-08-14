//
//  UIDrawerController.swift
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
//  Created by Nathan Tannar on 7/12/17.
//

import UIKit

public enum UIDrawerSide {
    case left, right, center
}

public enum UIDrawerControllerState {
    case leftExpanded, rightExpanded, collapsed
}

public struct UIDrawerSideProperties {
    
    public var side: UIDrawerSide
    
    /// The width of the views frame when visible
    public var width: CGFloat = 300
    
    /// If the view appears over or under the centerViewController
    public var isVisibleOnTop: Bool = true
    
    public var shadowOpacity: Float = 0.3
    public var shadowRadius: CGFloat = 2
    public var shadowColor: CGColor = UIColor.black.cgColor
    
    public var drawerAnimationDuration:       TimeInterval = 0.5
    public var drawerAnimationDelay:          TimeInterval = 0.0
    public var drawerAnimationSpringDamping:  CGFloat = 1.0
    public var drawerAnimationSpringVelocity: CGFloat = 1.0
    public var drawerAnimationStyle:          UIViewAnimationOptions = .curveLinear
    
    /// The view added to the edge of the view controller
    public var overflowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /// Extra animations that are called when openning a drawer side
    public var additionalOpenAnimations: (() -> Void)? = nil
    
    /// Extra animations that are called when closing a drawer side
    public var additionalCloseAnimations: (() -> Void)? = nil
    
    public func transform() -> CGAffineTransform {
        if side == .right {
            return CGAffineTransform(translationX: -width, y: 0)
        } else if side == .left {
            return CGAffineTransform(translationX: width, y: 0)
        }
        return CGAffineTransform.identity
    }
    
    public init(side: UIDrawerSide) {
        self.side = side
    }
}

public extension UIViewController {
    var drawerViewController: UIDrawerController? {
        var parentViewController = parent
        
        while parentViewController != nil {
            if let view = parentViewController as? UIDrawerController{
                return view
            }
            parentViewController = parentViewController!.parent
        }
        print("View controller did not have an UIDrawerController as a parent")
        return nil
    }
}

open class UIDrawerController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - View Controllers
    private var _centerViewController: UIViewController?
    private var _leftViewController:   UIViewController?
    private var _rightViewController:  UIViewController?
    
    // MARK: - State
    private var _currentState: UIDrawerControllerState = .collapsed
    
    // MARK: - Drawer View Properties
    open var leftViewProperties  = UIDrawerSideProperties(side: .left) {
        didSet {
            updateView(leftViewProperties)
        }
    }
    open var rightViewProperties = UIDrawerSideProperties(side: .right) {
        didSet {
            updateView(rightViewProperties)
        }
    }
    open var automaticallyAddMenuButtonItems: Bool = true
    
    open lazy var overlayView: UIView = { [weak self] in
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeDrawer))
        view.addGestureRecognizer(tapGesture)
        return view
        }()
    
    open var statusBar: UIView? {
        get {
            return UIApplication.shared.value(forKey: "statusBar") as? UIView
        }
    }
    
    open lazy var panGestureRecognizer: UIPanGestureRecognizer = { [weak self] in
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
        }()
    
    // MARK: - Initialization
    
    public convenience init(centerViewController: UIViewController) {
        self.init(centerViewController: centerViewController, leftViewController: nil, rightViewController: nil)
    }
    
    public convenience init(centerViewController: UIViewController, leftViewController: UIViewController) {
        self.init(centerViewController: centerViewController, leftViewController: leftViewController, rightViewController: nil)
    }
    
    public convenience init(centerViewController: UIViewController, rightViewController: UIViewController) {
        self.init(centerViewController: centerViewController, leftViewController: nil, rightViewController: rightViewController)
    }
    
    public required init(centerViewController: UIViewController, leftViewController: UIViewController?, rightViewController: UIViewController?) {
        self.init()
        _centerViewController = centerViewController
        _leftViewController = leftViewController
        _rightViewController = rightViewController
        setup()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Initializes the container
    open func setup() {
        addViewController(centerViewController, toSide: .center)
        addViewController(leftViewController, toSide: .left)
        addViewController(rightViewController, toSide: .right)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if activeSide == .right {
            updateView(rightViewProperties)
        }
    }
    
    // MARK: - UIDrawerController Methods
    
    /// Adds a view controllers view and parent pointer to 'UIDrawerController'
    ///
    /// - Parameter viewController: The view controller to remove
    private func addViewController(_ viewController: UIViewController?, toSide side: UIDrawerSide) {
        guard let vc = viewController else {
            return
        }
        
        
        vc.willMove(toParentViewController: self)
        addChildViewController(vc)
        vc.beginAppearanceTransition(true, animated: false)
        view.addSubview(vc.view)
        
        switch side {
        case .center:
            vc.view.frame = view.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addMenuBarButtonItems()
        case .left:
            vc.view.frame = CGRect(x: -leftViewProperties.width, y: 0, width: leftViewProperties.width, height: view.bounds.height)
            vc.view.autoresizingMask = [.flexibleHeight]
            vc.view.isHidden = true
            properties(forSide: .left)!.overflowView.translatesAutoresizingMaskIntoConstraints = false
            properties(forSide: .left)!.overflowView.removeConstraints(properties(forSide: .left)!.overflowView.constraints)
            properties(forSide: .left)!.overflowView.removeFromSuperview()
            vc.view.addSubview(properties(forSide: .left)!.overflowView)
            properties(forSide: .left)!.overflowView.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
            properties(forSide: .left)!.overflowView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
            properties(forSide: .left)!.overflowView.rightAnchor.constraint(equalTo: vc.view.leftAnchor).isActive = true
            properties(forSide: .left)!.overflowView.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
        case .right:
            vc.view.frame = CGRect(x: view.bounds.width, y: 0, width: rightViewProperties.width, height: view.bounds.height)
            vc.view.autoresizingMask = [.flexibleHeight]
            vc.view.isHidden = true
            
            // Add the overflow view
            properties(forSide: .right)!.overflowView.translatesAutoresizingMaskIntoConstraints = false
            properties(forSide: .right)!.overflowView.removeConstraints(properties(forSide: .right)!.overflowView.constraints)
            properties(forSide: .right)!.overflowView.removeFromSuperview()
            vc.view.addSubview(properties(forSide: .right)!.overflowView)
            properties(forSide: .right)!.overflowView.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
            properties(forSide: .right)!.overflowView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
            properties(forSide: .right)!.overflowView.leftAnchor.constraint(equalTo: vc.view.rightAnchor).isActive = true
            properties(forSide: .right)!.overflowView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        }
        
        vc.endAppearanceTransition()
        vc.didMove(toParentViewController: self)
    }
    
    
    /// Removes a view controllers view and parent pointer from 'UIDrawerController'
    ///
    /// - Parameter viewController: The view controller to remove
    private func removeViewController(_ viewController: UIViewController?) {
        guard let vc = viewController else {
            return
        }
        vc.willMove(toParentViewController: nil)
        vc.beginAppearanceTransition(false, animated: false)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
        vc.endAppearanceTransition()
    }
    
    
    /// Replaces a drawers view controller and updates the properties accordingly
    ///
    /// - Parameters:
    ///   - viewController: The view controller to add
    ///   - forSide: The side to set
    ///   - completion: Called when the replacement is complete
    open func setViewController(_ viewController: UIViewController, forSide side: UIDrawerSide, withProperties properties: UIDrawerSideProperties? = nil, completion: (() -> Void)? = nil) {
        
        var oldFrame: CGRect? = nil
        // Remove the previous controller
        if let oldViewController = self.viewController(forSide: side) {
            oldFrame = oldViewController.view.frame
            removeViewController(oldViewController)
        }
        // Set the new properties (if supplied)
        if let props = properties {
            if side == .left {
                leftViewProperties = props
            } else if side == .right {
                rightViewProperties = props
            }
        }
        addViewController(viewController, toSide: side)
        if oldFrame != nil {
            viewController.view.frame = oldFrame!
        }
        switch side {
        case .center:
            _centerViewController = nil
            _centerViewController = viewController
        case .left:
            _leftViewController = nil
            _leftViewController = viewController
            updateView(self.properties(forSide: side)!)
        case .right:
            _rightViewController = nil
            _rightViewController = viewController
            updateView(self.properties(forSide: side)!)
        }
        addMenuBarButtonItems(animated: false)
        completion?()
    }
    
    open func removeViewController(forSide side: UIDrawerSide) {
        switch side {
        case .center:
            removeViewController(_centerViewController)
            _centerViewController = nil
        case .left:
            removeViewController(_leftViewController)
            _leftViewController = nil
        case .right:
            removeViewController(_rightViewController)
            _rightViewController = nil
        }
    }
    
    
    /// If centerViewController is of type UINavigationController, a 'NTDrawerBarButtonItem' will be added to the rootViewController with an action to open the respective drawer side
    ///
    /// - Parameter animated: If items are added with an animation. Defaults to false
    open func addMenuBarButtonItems(animated: Bool = false) {
        if !automaticallyAddMenuButtonItems {
            return
        }
        
        guard let navigationController = _centerViewController as? UINavigationController else {
            return
        }
        
        if _leftViewController != nil {
            let barButtonItem = UIDrawerMenuItem(target: self, action: #selector(toggleLeftViewController(_:)))
            navigationController.viewControllers[0].navigationItem.setLeftBarButton(barButtonItem, animated: animated)
        }
        if _rightViewController != nil {
            let barButtonItem = UIDrawerMenuItem(target: self, action: #selector(toggleRightViewController(_:)))
            navigationController.viewControllers[0].navigationItem.setRightBarButton(barButtonItem, animated: animated)
        }
    }
    
    // MARK: - Drawer Toggles and Animations
    
    
    /// Toggles the view of the supplied size, closing the opposite side first if required
    ///
    /// - Parameters:
    ///   - side: Side to toggle
    ///   - completion: Executed when the animation was complete
    open func toggle(drawerSide side: UIDrawerSide, completion: (() -> Void)? = nil) {
        
        if activeSide == .center {
            open(drawerSide: side, completion: completion)
        } else if activeSide == side {
            close(drawerSide: side, completion: completion)
        } else {
            close(drawerSide: activeSide, completion: {
                self.open(drawerSide: side, completion: completion)
            })
        }
    }
    
    /// Closes the active drawer side
    open func closeDrawer() {
        toggle(drawerSide: activeSide)
    }
    
    /// Action for NTDrawerBarButtonItem that is added by default to the centerViewController
    open func toggleLeftViewController(_ sender: AnyObject? = nil) {
        toggle(drawerSide: .left)
    }
    
    /// Action for NTDrawerBarButtonItem that is added by default to the centerViewController
    open func toggleRightViewController(_ sender: AnyObject? = nil) {
        toggle(drawerSide: .right)
    }
    
    
    /// Opens a side drawer and performs the animations specified by the side parameter
    ///
    /// - Parameters:
    ///   - side: The side to open
    ///   - completion: Called when the animation is complete
    private func open(drawerSide side: UIDrawerSide, completion: (() -> Void)? = nil) {
        
        guard let properties = properties(forSide: side) else {
            return
        }
        
        updateView(properties)
        viewController(forSide: side)?.view.isHidden = false
        viewController(forSide: side)?.view.addGestureRecognizer(panGestureRecognizer)
        viewController(forSide: side)?.beginAppearanceTransition(true, animated: true)
        toggleOverlayView(isActive: true)
        
        UIView.animate(withDuration: properties.drawerAnimationDuration,
                       delay: properties.drawerAnimationDelay,
                       usingSpringWithDamping: properties.drawerAnimationSpringDamping,
                       initialSpringVelocity: properties.drawerAnimationSpringVelocity,
                       options: properties.drawerAnimationStyle, animations: {
                        
                        if properties.isVisibleOnTop {
                            self.viewController(forSide: side)?.view.transform = properties.transform()
                        } else {
                            self._centerViewController?.view.transform = properties.transform()
                        }
                        self.statusBar?.alpha = 0
                        self.overlayView.alpha = 0.2
                        properties.additionalOpenAnimations?()
                        
        }, completion: { finished in
            
            self.viewController(forSide: properties.side)?.endAppearanceTransition()
            self._currentState = self.state(forSide: side)
            completion?()
        })
    }
    
    /// Closes a side drawer and performs the animations specified by the side parameter
    ///
    /// - Parameters:
    ///   - side: The side to close
    ///   - completion: Called when the animation is complete
    private func close(drawerSide side: UIDrawerSide, completion: (() -> Void)? = nil) {
        
        guard let properties = properties(forSide: side) else {
            return
        }
        
        viewController(forSide: side)?.beginAppearanceTransition(false, animated: true)
        
        UIView.animate(withDuration: properties.drawerAnimationDuration,
                       delay: properties.drawerAnimationDelay,
                       usingSpringWithDamping: properties.drawerAnimationSpringDamping,
                       initialSpringVelocity: properties.drawerAnimationSpringVelocity,
                       options: properties.drawerAnimationStyle, animations: {
                        
                        if properties.isVisibleOnTop {
                            self.viewController(forSide: side)?.view.transform = CGAffineTransform.identity
                        } else {
                            self._centerViewController?.view.transform = CGAffineTransform.identity
                        }
                        self.statusBar?.alpha = 1
                        self.overlayView.alpha = 0
                        
                        properties.additionalCloseAnimations?()
                        
        }, completion: { finished in
            self.toggleOverlayView(isActive: false)
            self.viewController(forSide: properties.side)?.view.endEditing(true)
            self.viewController(forSide: properties.side)?.endAppearanceTransition()
            self.viewController(forSide: side)?.view.isHidden = true
            self.viewController(forSide: side)?.view.removeGestureRecognizer(self.panGestureRecognizer)
            self._currentState = .collapsed
            completion?()
        })
    }
    
    
    /// Brinds a side drawer back to its original openned state
    ///
    /// - Parameter side: The side to bounce back
    private func bounceBack(drawerSide side: UIDrawerSide) {
        
        guard let properties = properties(forSide: side) else {
            return
        }
        
        UIView.animate(withDuration: properties.drawerAnimationDuration,
                       delay: properties.drawerAnimationDelay,
                       usingSpringWithDamping: properties.drawerAnimationSpringDamping,
                       initialSpringVelocity: properties.drawerAnimationSpringVelocity,
                       options: properties.drawerAnimationStyle, animations: {
                        
                        if properties.isVisibleOnTop {
                            self.viewController(forSide: side)?.view.frame.origin.x = properties.side == .left ? 0 : self.view.bounds.width - properties.width
                        }
                        
        }, completion: nil)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    /// Specifies if the panGestureRecognizer should begin. Disables initial bounce effect
    ///
    /// - Parameter gestureRecognizer: gestureRecognizer
    /// - Returns: If the gesture can begin handling
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let gestureIsDraggingFromLeftToRight = (panGesture.velocity(in: view).x > 0)
        
        if currentState == .leftExpanded, gestureIsDraggingFromLeftToRight {
            return false
        }
        if currentState == .rightExpanded, !gestureIsDraggingFromLeftToRight {
            return false
        }
        return true
    }
    
    open func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let boundWidth = gestureRecognizer.view!.frame.origin.x
        
        guard let props = properties(forSide: activeSide), let activeView = viewController(forSide: activeSide)?.view else {
            return
        }
        
        switch(gestureRecognizer.state) {
        case .began, .changed:
            
            if props.isVisibleOnTop {
                var xPosition: CGFloat
                
                if props.side == .left {
                    xPosition = activeView.frame.origin.x
                    
                    if xPosition <= 30 {
                        gestureRecognizer.view!.center.x = gestureRecognizer.view!.center.x + gestureRecognizer.translation(in: activeView).x
                        gestureRecognizer.setTranslation(CGPoint.zero, in: activeView)
                    }
                } else if props.side == .right {
                    xPosition = activeView.frame.origin.x
                    
                    if xPosition >= (UIScreen.main.bounds.width - props.width - 30) {
                        gestureRecognizer.view!.center.x = gestureRecognizer.view!.center.x + gestureRecognizer.translation(in: activeView).x
                        gestureRecognizer.setTranslation(CGPoint.zero, in: activeView)
                    }
                }
            }
            
        case .ended:
            let shouldAutoClose = currentState == .leftExpanded ? -boundWidth > (props.width / 3) : boundWidth > (props.width / 3)
            if shouldAutoClose {
                close(drawerSide: activeSide)
            } else {
                bounceBack(drawerSide: activeSide)
            }
        default:
            break
        }
    }
    
    
    /// Called when the drawer controller is about to present a side or when a properties value has changed
    ///
    /// - Parameter properties: Properties used to update
    open func updateView(_ properties: UIDrawerSideProperties) {
        
        if activeSide == .center {
            
            if !properties.isVisibleOnTop {
                view.bringSubview(toFront: _centerViewController!.view)
                applyShadow(toViewController: _centerViewController, withProperties: properties)
            }
            
            if properties.side == .left {
                _leftViewController?.view.frame = CGRect(x: properties.isVisibleOnTop ? -leftViewProperties.width : 0, y: 0, width: leftViewProperties.width, height: view.bounds.height)
                if properties.isVisibleOnTop {
                    view.bringSubview(toFront: _leftViewController!.view)
                    applyShadow(toViewController: _leftViewController, withProperties: properties)
                    _leftViewController?.view.layer.shadowOffset = CGSize(width: 3, height: 0)
                } else {
                    _centerViewController?.view.layer.shadowOffset = CGSize(width: -3, height: 0)
                }
            } else if properties.side == .right {
                _rightViewController?.view.frame = CGRect(x: view.bounds.width - (properties.isVisibleOnTop ? 0 : rightViewProperties.width), y: 0, width: rightViewProperties.width, height: view.bounds.height)
                if properties.isVisibleOnTop {
                    view.bringSubview(toFront: _rightViewController!.view)
                    applyShadow(toViewController: _rightViewController, withProperties: properties)
                    _rightViewController?.view.layer.shadowOffset = CGSize(width: -3, height: 0)
                } else {
                    _centerViewController?.view.layer.shadowOffset = CGSize(width: 3, height: 0)
                }
            }
        } else {
            
            // Update center view controller and status bar transform
            self.statusBar?.alpha = 0
            UIView.animate(withDuration: properties.drawerAnimationDuration,
                           delay: properties.drawerAnimationDelay,
                           usingSpringWithDamping: properties.drawerAnimationSpringDamping,
                           initialSpringVelocity: properties.drawerAnimationSpringVelocity,
                           options: properties.drawerAnimationStyle, animations: {
                            
                            if !properties.isVisibleOnTop {
                                self.applyShadow(toViewController: self._centerViewController, withProperties: properties)
                                self._centerViewController?.view.transform = properties.transform()
                            } else {
                                self._centerViewController?.view.transform = CGAffineTransform.identity
                            }
                            
            }, completion: { success in
                if !properties.isVisibleOnTop {
                    self.view.bringSubview(toFront: self._centerViewController!.view)
                }
            })
            
            if properties.side == .left {
                _leftViewController?.beginAppearanceTransition(true, animated: false)
                _leftViewController?.view.frame = CGRect(x: 0, y: 0, width: leftViewProperties.width, height: view.bounds.height)
                if properties.isVisibleOnTop {
                    view.bringSubview(toFront: _leftViewController!.view)
                    applyShadow(toViewController: _leftViewController, withProperties: properties)
                    _leftViewController?.view.layer.shadowOffset = CGSize(width: 3, height: 0)
                } else {
                    _centerViewController?.view.layer.shadowOffset = CGSize(width: -3, height: 0)
                }
                _leftViewController?.endAppearanceTransition()
            } else if properties.side == .right {
                _rightViewController?.beginAppearanceTransition(true, animated: false)
                _rightViewController?.view.frame = CGRect(x: view.bounds.width - rightViewProperties.width, y: 0, width: rightViewProperties.width, height: view.bounds.height)
                if properties.isVisibleOnTop {
                    view.bringSubview(toFront: _rightViewController!.view)
                    applyShadow(toViewController: _rightViewController, withProperties: properties)
                    _rightViewController?.view.layer.shadowOffset = CGSize(width: -3, height: 0)
                } else {
                    _centerViewController?.view.layer.shadowOffset = CGSize(width: 3, height: 0)
                }
                _rightViewController?.endAppearanceTransition()
            }
        }
    }
    
    private func applyShadow(toViewController viewController: UIViewController?, withProperties props: UIDrawerSideProperties) {
        viewController?.view.layer.shadowColor = props.shadowColor
        viewController?.view.layer.shadowRadius = props.shadowRadius
        viewController?.view.layer.shadowOpacity = props.shadowOpacity
    }
    
    open func toggleOverlayView(isActive: Bool) {
        if isActive, overlayView.superview == nil {
            _centerViewController?.view.addSubview(overlayView)
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            overlayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            overlayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        } else {
            overlayView.removeConstraints(overlayView.constraints)
            overlayView.removeFromSuperview()
        }
    }
    
    // MARK: - Accessor Variables
    
    /// Accessor to the centerViewController
    open var centerViewController: UIViewController? {
        get {
            return _centerViewController
        }
    }
    
    /// Accessor to the leftViewController
    open var leftViewController: UIViewController? {
        get {
            return _leftViewController
        }
    }
    
    /// Accessor to the rightViewController
    open var rightViewController: UIViewController? {
        get {
            return _rightViewController
        }
    }
    
    /// Assuming centerViewController is of type UINavigationController its first child view controller will be returned
    open var rootViewController: UIViewController? {
        get {
            return (_centerViewController as? UINavigationController)?.viewControllers[0]
        }
    }
    
    /// Accessor to the currentStae
    open var currentState: UIDrawerControllerState {
        get {
            return _currentState
        }
    }
    
    /// Accessor to the current side that is presenting
    open var activeSide: UIDrawerSide {
        get {
            switch _currentState {
            case .collapsed:
                return .center
            case .leftExpanded:
                return .left
            case .rightExpanded:
                return .right
            }
        }
    }
    
    // MARK: - Mapping Methods
    
    
    /// Returns the correct drawer properties held by UIDrawerController for the respective side
    ///
    /// - Parameter side: Properties side to return
    /// - Returns: The properties for the respective side
    public func properties(forSide side: UIDrawerSide) -> UIDrawerSideProperties? {
        switch side {
        case .left:
            return leftViewProperties
        case .right:
            return rightViewProperties
        default:
            return nil
        }
    }
    
    
    /// Maps a UIDrawerControllerState to UIDrawerSide
    ///
    /// - Parameter side: UIDrawerSide to map
    /// - Returns: The mapped UIDrawerControllerState
    public func state(forSide side: UIDrawerSide) -> UIDrawerControllerState {
        switch side {
        case .center:
            return .collapsed
        case .left:
            return .leftExpanded
        case .right:
            return .rightExpanded
        }
    }
    
    
    /// Maps an UIDrawerSide to its respective controller
    ///
    /// - Parameter side: UIDrawerSide to map
    /// - Returns: The view controller for the given side
    public func viewController(forSide side: UIDrawerSide) -> UIViewController? {
        switch side {
        case .center:
            return _centerViewController
        case .left:
            return _leftViewController
        case .right:
            return _rightViewController
        }
    }
}

