//
//  ViewController.swift
//  VR图片浏览
//
//  Created by 黄进文 on 2017/1/6.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(fireButton)
        view.addSubview(dubaiButton)
        view.addSubview(snowButton)
    }
    
    // MARK: 监听方法
    @objc fileprivate func fireButtonClick(sender: UIButton) {
        
        var filePath: String? = nil
        if sender.tag == 1 {
            
            filePath = Bundle.main.path(forResource: "huoshang", ofType: "jpg")!
        }
        else if sender.tag == 2 {
            
            filePath = Bundle.main.path(forResource: "dubai", ofType: "jpg")!
        }
        else if sender.tag == 3 {
            
            filePath = Bundle.main.path(forResource: "snow", ofType: "jpg")!
        }
        let photoVC = MMPhotoViewController(nibName: nil, bundle: nil, urlString: filePath)
        present(photoVC, animated: true, completion: nil)
    }
    
    // MARK: lazy
    /// 火山
    fileprivate lazy var fireButton: UIButton = {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 100, y: 150, width: 200, height: 48)
        btn.setTitle("火 山", for: UIControlState.normal)
        btn.backgroundColor = UIColor(red: 250 / 255.0, green: 60 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        btn.tag = 1
        btn.layer.cornerRadius = 24
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(ViewController.fireButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    /// 迪拜
    fileprivate lazy var dubaiButton: UIButton = {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 100, y: 250, width: 200, height: 48)
        btn.setTitle("迪 拜", for: UIControlState.normal)
        btn.backgroundColor = UIColor(red: 40 / 255.0, green: 180 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        btn.tag = 2
        btn.layer.cornerRadius = 24
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(ViewController.fireButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    /// 雪山
    fileprivate lazy var snowButton: UIButton = {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 100, y: 350, width: 200, height: 48)
        btn.setTitle("雪 山", for: UIControlState.normal)
        btn.backgroundColor = UIColor(red: 90 / 255.0, green: 90 / 255.0, blue: 250 / 255.0, alpha: 1.0)
        btn.tag = 3
        btn.layer.cornerRadius = 24
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(ViewController.fireButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        return btn
    }()
}







































