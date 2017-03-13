//
//  MMScrollNavigationViewController.swift
//  MMNavigationBar
//
//  Created by 黄进文 on 2017/3/7.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

/**
 A custom `UIViewController` that implements the base configuration.
 */
open class MMScrollNavigationViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - ScrollView config
    /// On appear calls `showNavbar()` by default
    open override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController as? MMScrollNavigationController {
            
            navigationController.showNavigationBar(animated: true, duration: 0.1)
        }
    }
    
    /// On disappear calls `stopFollowingScrollView()` to stop observing the current scroll view, and perform the tear down
    open override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController as? MMScrollNavigationController {
            
            navigationController.stopFollowingScrollView()
        }
    }
    
    /// Calls `showNavbar()` when a `scrollToTop` is requested
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        if let navigationController = self.navigationController as? MMScrollNavigationController {
            
            navigationController.showNavigationBar(animated: true, duration: 0.1)
        }
        return true
    }
}





























