

# VRPhoto

VR全景图片浏览器，喜欢就点下star哈☺️

[实现思路](http://www.jianshu.com/p/61dc85ff79d2)

------

在VRPhotoLib文件夹中有个文件Bridging-Header.h需要进行桥接.

![桥接文件示意图](https://github.com/evenCoder/VRPhoto/blob/master/Images/qiaojiewenjian.png)

如何使用，如下:

``` 
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	let filePath = Bundle.main.path(forResource: bundle + photos[indexPath.row], ofType: "jpg")!
    let photoVC = MMPhotoViewController(nibName: nil, bundle: nil, urlString: filePath)
    present(photoVC, animated: true, completion: nil)
}
```

注: NavigationBarLib文件夹是实现导航栏的隐藏和显示，值得学习。

------

VR全景图片示例:

![紫禁城](https://github.com/evenCoder/VRPhoto/blob/master/Images/zijincheng.gif)

------