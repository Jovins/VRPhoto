//
//  MMScrollNavigationBar+Size.swift
//  MMNavigationBar
//
//  Created by 黄进文 on 2017/3/7.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

/// Implements the main functions providing constants values and computed ones
extension MMScrollNavigationController {
    
    // MARK: - View Sizing
    var fullNavigationBarHeight: CGFloat {
        
        return navigationBarHeight + statusBarHeight
    }
    
    var navigationBarHeight: CGFloat {
        
        return navigationBar.frame.size.height
    }
    
    var statusBarHeight: CGFloat {
        
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    var tabBarOffset: CGFloat {
        
        /// Only account for the tab bar if a tab bar controller is present and the bar is not translucent
        if let tabBarController = tabBarController {
            
            return tabBarController.tabBar.isTranslucent ? 0 : tabBarController.tabBar.frame.height
        }
        return 0
    }
    
    func scrollView() -> UIScrollView? {
        
        if let webView = self.scrollableView as? UIWebView {
            
            return webView.scrollView
        }
        else {
            
            return scrollableView as? UIScrollView
        }
    }
    
    var contentOffset: CGPoint {
        
        return scrollView()?.contentOffset ?? CGPoint.zero
    }
    
    var contentSize: CGSize {
        
        return scrollView()?.contentSize ?? CGSize.zero
    }
    
    var deltaLimit: CGFloat {
        
        return navigationBarHeight - statusBarHeight
    }
}









































