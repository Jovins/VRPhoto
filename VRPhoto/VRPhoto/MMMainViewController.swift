//
//  MMMainViewController.swift
//  VRPhoto
//
//  Created by 黄进文 on 2017/3/13.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

let bundle = "Images.bundle/"

class MMMainViewController: MMScrollNavigationViewController {

    let photos: [String] = ["zijincheng", "dubai", "huoshang", "snow", "balitieta", "daxiagu", "dubaipark", "dubaimatou", "dubaishangwuqu", "fangchuan", "jiuzhaigou", "kaixuanmen", "shenmiao", "xuejing", "zhangjiajie", "changcheng"]
    let titles: [String] = ["紫禁城", "迪拜塔", "火山", "下雪", "巴黎铁塔", "大峡谷", "迪拜公园", "迪拜码头", "迪拜商务区", "帆船酒店", "九寨沟", "凯旋门", "希腊神庙", "雪景", "张家界", "长城"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "VRPhoto"
        view.backgroundColor = UIColor.white
        
        setupUI()
    }
    
    // MARK: - 生命周期方法
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(red: 250 / 255.0, green: 60 / 255.0, blue: 50 / 255.0, alpha: 1.0)

        if let navigationController = self.navigationController as? MMScrollNavigationController {
            
            navigationController.followScrollView(tableView, delay: 0.0)
            navigationController.scrollNavigationBarDelegate = self
        }
    }
    
    // MARK: - 内部控制方法
    fileprivate func setupUI() {
        
        tableView.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        view.addSubview(tableView)
    }
    
    // MARK: - 懒加载

    fileprivate lazy var tableView: UITableView = {
        
        let table = UITableView()
        // 注册
        table.register(MMPhotoCell.self, forCellReuseIdentifier: "Identifier")
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 210
        return table
    }()
}

// MARK: - Table view data source
extension MMMainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Identifier", for: indexPath) as! MMPhotoCell
        cell.photoView.image = UIImage(named: bundle + photos[indexPath.row] + ".jpg")
        cell.title.text = titles[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MMMainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let filePath = Bundle.main.path(forResource: bundle + photos[indexPath.row], ofType: "jpg")!
        let title = titles[indexPath.row]
        let photoVC = MMPhotoViewController(nibName: nil, bundle: nil, urlString: filePath, title: title)
        present(photoVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if photos.count != 0 {
            
            var rotation = CATransform3DMakeTranslation(0, 50, 50)
            rotation = CATransform3DScale(rotation, 0.9, 0.9, 1)
            rotation.m34 = 1.0 / -600
            
            cell.layer.shadowColor = UIColor.white.cgColor
            cell.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
            cell.alpha = 0
            cell.layer.transform = rotation
            UIView.beginAnimations("rotation", context: nil)
            UIView.setAnimationDuration(0.5)
            cell.layer.transform = CATransform3DIdentity  // 恢复
            cell.alpha = 1
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            UIView.commitAnimations()
        }
    }
}

// MARK: - MMPhotoCell
class MMPhotoCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = UITableViewCellSelectionStyle.none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        
        contentView.addSubview(photoView)
        
        title.width = photoView.width
        title.center = photoView.center
        contentView.addSubview(title)
    }
    
    // MARK: - cell懒加载
    fileprivate lazy var photoView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 210.0)
        return imageView
    }()
    
    fileprivate lazy var title: UILabel = {
        
        let label = UILabel()
        label.text = "测试"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.sizeToFit()
        return label
    }()
}

//MARK: - MMScrollNavigationControllerDelegate
extension MMMainViewController: MMScrollNavigationControllerDelegate {
    
    func mmScrollNavigationController(_ controller: MMScrollNavigationController, didChangeState state: NavigationBarState) {
        
    }
}























