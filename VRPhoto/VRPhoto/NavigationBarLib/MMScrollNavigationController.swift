//
//  MMScrollNavigationController.swift
//  MMNavigationBar
//
//  Created by 黄进文 on 2017/3/7.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

/**
 The state of the navigation bar
 
 - collapsed: the navigation bar is fully collapsed
 - expanded: the navigation bar is fully visible
 - scrolling: the navigation bar is transitioning to either `Collapsed` or `Scrolling`
 */
@objc public enum NavigationBarState: Int {
    
    case collapsed, expanded, scrolling
}

// MARK: - Scrolling Navigation Bar delegate protocol
@objc public protocol MMScrollNavigationControllerDelegate: NSObjectProtocol {
    
    /// Called when the state of the navigation bar changes
    @objc optional func mmScrollNavigationController(_ controller: MMScrollNavigationController, didChangeState state: NavigationBarState)
    
    /// Called when the state of the navigation bar is about to change
    @objc optional func mmScrollNavigationController(_ controller: MMScrollNavigationController, willChangeState state: NavigationBarState)
}

open class MMScrollNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    // MARK: - 属性
    /// Returns the `NavigationBarState` of the navigation bar
    open fileprivate(set) var state: NavigationBarState = .expanded {
        
        willSet {
            
            if state != newValue {
                
                scrollNavigationBarDelegate?.mmScrollNavigationController?(self, willChangeState: newValue)
            }
        }
        
        didSet {
            
            navigationBar.isUserInteractionEnabled = (state == .expanded)
            if state != oldValue {
                
                scrollNavigationBarDelegate?.mmScrollNavigationController?(self, didChangeState: state)
            }
        }
    }
    
    /// The delegate for the scrolling navbar controller
    open weak var scrollNavigationBarDelegate: MMScrollNavigationControllerDelegate?
    
    /// Determines whether the navbar should scroll when the content inside the scrollview fits the view's size. Defaults to `false`
    open var shouldScrollWhenContentFits: Bool = false
    
    /// Determines if the navbar should expand once the application becomes active after entering background Defaults to `true`
    open var expendedOnActive: Bool = true
    
    /// Determines if the navbar scrolling is enabled Defaults to `true`
    open var scrollingEnabled = true
    
    /// An array of `UIView`s that will follow the navbar
    open var followers: [UIView] = []
    
    open fileprivate(set) var gestureRecongnizer: UIPanGestureRecognizer?
    var delayDistance: CGFloat = 0
    var maxDelay: CGFloat = 0
    var scrollableView: UIView?
    var lastContentOffset = CGFloat(0.0)
    var scrollSpeedFactor: CGFloat = 1.0
    
    // MARK: - 外部方法
    /// Start scrolling Enables the scrolling by observing a view
    open func followScrollView(_ scrollableView: UIView, delay: Double = 0, scrollSpeedFactor: Double = 1, followers: [UIView] = []) {
        
        self.scrollableView = scrollableView
        
        gestureRecongnizer = UIPanGestureRecognizer(target: self, action: #selector(MMScrollNavigationController.handlePan(_:)))
        gestureRecongnizer?.maximumNumberOfTouches = 1
        gestureRecongnizer?.delegate = self
        scrollableView.addGestureRecognizer(gestureRecongnizer!)
        
        /// 通知
        NotificationCenter.default.addObserver(self, selector: #selector(MMScrollNavigationController.didBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MMScrollNavigationController.didRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        maxDelay = CGFloat(delay)
        delayDistance = CGFloat(delay)
        scrollingEnabled = true
        self.followers = followers
        self.scrollSpeedFactor = CGFloat(scrollSpeedFactor)
    }
    
    /// Hide the navigation bar
    public func hideNavigationBar(animated: Bool = true, duration: TimeInterval = 0.1) {
        
        guard let _ = self.scrollableView, let visibleViewController = self.visibleViewController else {
            
            return
        }
        
        if state == .expanded {
            
            self.state = .scrolling
            UIView.animate(withDuration: animated ? duration : 0, animations: { 
                
                self.scrollWithDelta(self.fullNavigationBarHeight)
                visibleViewController.view.setNeedsLayout()
                if self.navigationBar.isTranslucent {
                    
                    let currentOffset = self.contentOffset
                    self.scrollView()?.contentOffset = CGPoint(x: currentOffset.x, y: currentOffset.y + self.navigationBarHeight)
                }
            }, completion: { (_) in
                
                self.state = .collapsed
            })
        }
        else {
            
            updateNavigationBarAlpha()
        }
    }
    
    /// Show the navigation bar
    public func showNavigationBar(animated: Bool = true, duration: TimeInterval = 0.1) {
        
        guard let _ = self.scrollableView, let visibleViewController = self.visibleViewController else {
            
            return
        }
        
        if state == .collapsed {
            
            gestureRecongnizer?.isEnabled = false
            self.state = .scrolling
            UIView.animate(withDuration: animated ? duration : 0.0, animations: { 
                
                self.lastContentOffset = 0
                self.delayDistance = -self.fullNavigationBarHeight
                self.scrollWithDelta(-self.fullNavigationBarHeight)
                visibleViewController.view.setNeedsLayout()
                if self.navigationBar.isTranslucent {
                    
                    let currentOffset = self.contentOffset
                    self.scrollView()?.contentOffset = CGPoint(x: currentOffset.x, y: currentOffset.y - self.navigationBarHeight)
                }
                
            }, completion: { (_) in
                
                self.state = .expanded
                self.gestureRecongnizer?.isEnabled = true
            })
        }
        else {
            
            updateNavigationBarAlpha()
        }
    }
    
    /// Stop observing the view and reset the navigation bar
    public func stopFollowingScrollView() {
        
        showNavigationBar(animated: false, duration: 0.1)
        if let gesture = gestureRecongnizer {
            
            scrollableView?.removeGestureRecognizer(gesture)
        }
        scrollableView = .none
        gestureRecongnizer = .none
        scrollNavigationBarDelegate = .none
        scrollingEnabled = false
        let center = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        center.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // MARK: - gesture监听方法
    @objc fileprivate func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        if gesture.state != .failed {
            
            if let superview = scrollableView?.superview {
                
                let translation = gesture.translation(in: superview)
                let delta = lastContentOffset - translation.y
                lastContentOffset = translation.y
                
                if shouldScrollWithDelta(delta) {
                    
                    scrollWithDelta(delta)
                }
            }
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            
            checkForPartialScroll()
            lastContentOffset = 0
        }
    }
    
    // MARK: - NotificationCenter监听方法
    @objc fileprivate func didBecomeActive(_ notification: Notification) {
        
        if expendedOnActive {
            
            showNavigationBar(animated: false)
        }
    }
    
    /// Handles when the status bar changes
    func willChangeStatusBar() {
        
        showNavigationBar(animated: true)
    }
    
    // MARK: - Rotation监听方法
    @objc fileprivate func didRotate(_ notification: Notification) {
        
        showNavigationBar()
    }
    
    /**
     UIContentContainer protocol method.
     Will show the navigation bar upon rotation or changes in the trait sizes.
     */
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        showNavigationBar()
    }
    
    // MARK: - 内部控制方法
    fileprivate func checkForPartialScroll() {
        
        let frame = navigationBar.frame
        var duration = TimeInterval(0)
        var delta = CGFloat(0.0)
        let distance = delta / (frame.size.height / 2)
        
        /// Scroll back down
        let threshold = statusBarHeight - (frame.size.height / 2)
        if navigationBar.frame.origin.y >= threshold {
            delta = frame.origin.y - statusBarHeight
            duration = TimeInterval(abs(distance * 0.2))
            state = .expanded
        } else {
            // Scroll up
            delta = frame.origin.y + deltaLimit
            duration = TimeInterval(abs(distance * 0.2))
            state = .collapsed
        }
        
        delayDistance = maxDelay
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            
            self.updateSizing(delta)
            self.updateFollowers(delta)
            self.updateNavigationBarAlpha()
        }, completion: nil)
    }
    
    fileprivate func shouldScrollWithDelta(_ delta: CGFloat) -> Bool {
        
        if delta < 0 {
            
            if let scrollableView = scrollableView, contentOffset.y + scrollableView.frame.size.height > contentSize.height && scrollableView.frame.size.height < contentSize.height {
                
                return false
            }
        }
        else {
            
            if contentOffset.y < 0 {
                
                return false
            }
        }
        return true
    }
    
    fileprivate func scrollWithDelta(_ delta: CGFloat) {
        
        var scrollDelta = delta / scrollSpeedFactor
        let frame = navigationBar.frame
        
        /// View scrolling up, hide the navbar
        if scrollDelta > 0 {
            
            delayDistance -= scrollDelta /// Update the delay
            
            /// Skip if the delay is not over yet
            if delayDistance > 0 {
                
                return
            }
            
            /// No need to scroll if the content fits
            if !shouldScrollWhenContentFits && state != .collapsed && (scrollableView?.frame.size.height)! >= contentSize.height {
                
                return
            }
            
            /// Compute the bar position
            if frame.origin.y - scrollDelta < -deltaLimit {
                
                scrollDelta = frame.origin.y + deltaLimit
            }
            
            /// Detect when the bar is completely collapsed
            if frame.origin.y <= -deltaLimit {
                
                state = .collapsed
                delayDistance = maxDelay
            }
            else {
                
                state = .scrolling
            }
        }
        
        if scrollDelta < 0 {
            
            delayDistance += scrollDelta /// Update the delay
            
            /// Skip if the delay is not over yet
            if delayDistance > 0 && maxDelay < contentOffset.y {
                
                return
            }
            
            /// Compute the bar position
            if frame.origin.y - scrollDelta > statusBarHeight {
                
                scrollDelta = frame.origin.y - statusBarHeight
            }
            
            /// Detect when the bar is completely expanded
            if frame.origin.y >= statusBarHeight {
                
                state = .expanded
                delayDistance = maxDelay
            }
            else {
                
                state = .scrolling
            }
        }
        
        updateSizing(scrollDelta)
        updateNavigationBarAlpha()
        updateContentOffset(scrollDelta)
        updateFollowers(scrollDelta)
    }
    
    fileprivate func updateContentOffset(_ delta: CGFloat) {
        
        if navigationBar.isTranslucent || delta == 0 {
            
            return
        }
        /// Hold the scroll steady until the navbar appears/disappears
        if let scrollView = scrollView() {
            
            scrollView.setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y - delta), animated: false)
        }
    }
    
    fileprivate func updateFollowers(_ delta: CGFloat) {
        
        followers.forEach { $0.transform = $0.transform.translatedBy(x: 0, y: -delta)}
    }

    fileprivate func updateSizing(_ delta: CGFloat) {
        
        guard let topViewController = self.topViewController else {
            
            return
        }
        
        /// Move the navigation bar
        var frame = navigationBar.frame
        frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y - delta)
        navigationBar.frame = frame
        
        /// Resize the view if the navigation bar is not translucent
        if !navigationBar.isTranslucent {
            
            let navBarY = navigationBar.frame.origin.y + navigationBar.frame.size.height
            frame = topViewController.view.frame
            frame.origin = CGPoint(x: frame.origin.x, y: navBarY)
            frame.size = CGSize(width: frame.size.width, height: view.frame.size.height - navBarY - tabBarOffset)
            topViewController.view.frame = frame
        }
        else {
            
            if let view = scrollView() as? UICollectionView {
                
                view.contentInset.top = navigationBar.frame.origin.y + navigationBar.frame.size.height
                view.setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y - 0.1), animated: false)
            }
        }
    }
    
    fileprivate func updateNavigationBarAlpha() {
        
        guard let navigationItem = visibleViewController?.navigationItem else {
            
            return
        }
        
        /// Change the alpha channel of every item on the navbr
        let frame = navigationBar.frame
        let alpha = (frame.origin.y + deltaLimit) / frame.size.height
        navigationItem.titleView?.alpha = alpha
        navigationBar.tintColor = navigationBar.tintColor.withAlphaComponent(alpha)
        if let titileColor = navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor {
            
            navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = titileColor.withAlphaComponent(alpha)
        }
        else {
            
            navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = UIColor.black.withAlphaComponent(alpha)
        }
        
        // Hide all possible button items and navigation items
        func shouldHideView(_ view: UIView) -> Bool {
            
            let className = view.classForCoder.description()
            return className == "UINavigationButton" ||
                className == "UINavigationItemView" ||
                className == "UIImageView" ||
                className == "UISegmentedControl"
        }
        navigationBar.subviews.filter(shouldHideView)
            .forEach { $0.alpha = alpha }
        
        /// Hide the left items
        navigationItem.leftBarButtonItem?.customView?.alpha = alpha
        if let letItems = navigationItem.leftBarButtonItems {
            
            letItems.forEach { $0.customView?.alpha = alpha }
        }
        
        /// Hide the right items
        navigationItem.rightBarButtonItem?.customView?.alpha = alpha
        if let rightItems = navigationItem.rightBarButtonItems {
            rightItems.forEach { $0.customView?.alpha = alpha }
        }
    }
    
    //MARK: - UIGestureRecognizerDelegate
    /// UIGestureRecognizerDelegate function. Enables the scrolling of both the content and the navigation bar
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    /// UIGestureRecognizerDelegate function. Only scrolls the navigation bar with the content when `scrollingEnabled` is true
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        return scrollingEnabled
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
}












































