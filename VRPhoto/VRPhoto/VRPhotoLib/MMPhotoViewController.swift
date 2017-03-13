//
//  MMPhotoViewController.swift
//  VR图片浏览
//
//  Created by 黄进文 on 2017/2/25.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

class MMPhotoViewController: UIViewController {

    
    fileprivate var photoUrl: String?
    
    fileprivate var titleStr: String?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, urlString: String?, title: String?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        guard let url = urlString else {
            
            return
        }
        
        photoUrl = url
        titleStr = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let photo = MMPhotoView(frame: view.bounds)
        photo.photoURL = photoUrl
        view.addSubview(photo)
        view.addSubview(closeButton)
        
        titleString.text = titleStr
        view.addSubview(titleString)
    }
    
    @objc fileprivate func closeButtonClick() {
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - 懒加载
    fileprivate lazy var closeButton: UIButton = {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 10, y: 20, width: 50, height: 50)
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.setImage(UIImage(named: "Images.bundle/" + "close"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(MMPhotoViewController.closeButtonClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    fileprivate lazy var titleString: UILabel = {
        
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.frame = CGRect(x: 10.0, y: 20.0, width: UIScreen.main.bounds.width - 10.0, height: 35)
        return label
    }()
}
















