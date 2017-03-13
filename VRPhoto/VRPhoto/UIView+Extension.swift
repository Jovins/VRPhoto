//
//  UIView+Extension.swift
//  Genius
//
//  Created by 黄进文 on 2017/1/11.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit

extension UIView {
    
    public var x: CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var f = self.frame
            f.origin.x = newValue
            self.frame = f
        }
    }
    
    public var y: CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            var f = self.frame
            f.origin.y = newValue
            self.frame = f
        }
    }
    
    public var top: CGFloat{
        
        get {
            return self.frame.origin.y
        }
        set{
            
            var f = self.frame
            f.origin.y = newValue
            self.frame = f
        }
    }
    
    public var bottom: CGFloat{
        
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set{
            
            var f = self.frame
            f.origin.y = newValue - self.frame.size.height
            self.frame = f
        }
    }
    
    public var left: CGFloat {
        
        get {
            
            return self.frame.origin.x
        }
        set {
            
            var f = self.frame
            f.origin.x = newValue
            self.frame = f
        }
    }
    
    public var right: CGFloat {
        
        get {
            
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            
            var f = self.frame
            f.origin.x = newValue - self.frame.size.width
            self.frame = f
        }
    }
    
    public var width: CGFloat{
        
        get {
            return self.frame.size.width
        }
        set{
            
            var r = self.frame
            r.size.width = newValue
            self.frame = r
        }
        
    }
    
    public var height: CGFloat{
        
        get {
            return self.frame.size.height
        }
        set{
            
            var r = self.frame
            r.size.height = newValue
            self.frame = r
        }
    }
    
    public var centerX: CGFloat {
        
        get {
            
            return self.center.x
        }
        set {
            
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    
    public var centerY: CGFloat {
        
        get {
            
            return self.center.y
        }
        set {
            
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
    
    public var size: CGSize {
        
        get {
            
            return self.frame.size
        }
        set {
            
            var s = self.frame.size
            s = newValue
            self.frame.size = s
        }
    }
}






