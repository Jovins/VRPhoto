//
//  MMNavigationController.swift
//  VRPhoto
//
//  Created by 黄进文 on 2017/3/13.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

class MMNavigationController: MMScrollNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    /// 修改状态栏颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return UIStatusBarStyle.lightContent
    }
}
