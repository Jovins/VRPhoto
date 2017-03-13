//
//  MMPhotoView.swift
//  VR图片浏览
//
//  Created by 黄进文 on 2017/2/21.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

import UIKit
import GLKit
import CoreMotion

fileprivate let ES_PI = 3.14159265 /// 圆周率

class MMPhotoView: GLKView, GLKViewDelegate {

    /// 传过来的VR全景图片路径
    public var photoURL: String? {
        
        didSet {
            
            guard let filePath = photoURL else {
                
                return
            }
            
            /// 将图片转为纹理信息
            runningTexture(filePath)
        }
    }
    
    /// 相机广角角度
    fileprivate var overture: CGFloat = 0
    /// 索引数
    fileprivate var numIndices: Int = 0
    /// 顶点索引缓存指针
    fileprivate var vertexIndicesBufferID: GLuint = 0
    /// 顶点缓存指针
    fileprivate var vertexBufferID: GLuint = 0
    /// 纹理缓存指针
    fileprivate var vertexTexCoordID: GLuint = 0
    
    /// 着色器
    fileprivate var effect: GLKBaseEffect?
    /// 图片纹理信息
    fileprivate var textureInfo: GLKTextureInfo?
    /// 模型坐标系
    fileprivate var modelViewMatrix: GLKMatrix4 = GLKMatrix4Identity
    
    /// 拖拽手势
    fileprivate var panX: CGFloat = 0
    fileprivate var panY: CGFloat = 0
    
    let sphereSliceNum = 200
    let sphereRadius = 1.0   /// 球体半径
    let sphereScale = 300

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        /// 初始化GLKView
        setupGLKView()
        
        /// 设置buffers
        setupBuffer()
        
        /// 检测屏幕位置(加速器与陀螺仪)
        startDeviceMotion()
        
        /// 添加拖拽手势
        addPanGestureRecognizer()
        
        addDisplayLink()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - GLKViewDelegate
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        // 清除缓冲区的内容
        glClearColor(0, 0, 0, 1)
        // 清除颜色缓冲区与深度缓冲区内容
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        // 渲染着色器
        effect?.prepareToDraw()
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(numIndices), GLenum(GL_UNSIGNED_SHORT), nil)
        
        update()
    }
    
    // MARK: - 生命周期方法    
    fileprivate func update() {
        
        let aspect: Float = fabs(Float(bounds.size.width) / Float(bounds.size.height))
        var projectionMatrix: GLKMatrix4 = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), aspect, 0.1, 400.0)
        projectionMatrix = GLKMatrix4Scale(projectionMatrix, -1.0, 1.0, 1.0)
        
        if motionManager.deviceMotion != nil {
            
            let w: Float = Float(motionManager.deviceMotion!.attitude.quaternion.w)
            let x: Float = Float(motionManager.deviceMotion!.attitude.quaternion.x)
            let y: Float = Float(motionManager.deviceMotion!.attitude.quaternion.y)
            let z: Float = Float(motionManager.deviceMotion!.attitude.quaternion.z)
            
            projectionMatrix = GLKMatrix4RotateX(projectionMatrix, -(Float)(0.005 * panY))
            
            let quaternion: GLKQuaternion = GLKQuaternionMake(-x, y, z, w)
            let rotation: GLKMatrix4 = GLKMatrix4MakeWithQuaternion(quaternion)
            
            projectionMatrix = GLKMatrix4Multiply(projectionMatrix, rotation)
            
            /// 为了保证在水平放置手机的时候, 是从下往上看, 因此首先坐标系沿着x轴旋转90度
            projectionMatrix = GLKMatrix4RotateX(projectionMatrix, -Float(M_PI_2))
            effect?.transform.projectionMatrix = projectionMatrix
            
            var modelViewMatrix: GLKMatrix4 = GLKMatrix4Identity
            modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, Float(0.005 * panX))
            effect?.transform.modelviewMatrix = modelViewMatrix
        }
    }

    
    // MARK: - 内部控制方法
    fileprivate func setupGLKView() {
        
        /// 设置颜色格式和深度格式
        drawableColorFormat = GLKViewDrawableColorFormat.RGBA8888
        drawableDepthFormat = GLKViewDrawableDepthFormat.format24
        self.delegate = self
        context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2)
        //将此“EAGLContext”实例设置为OpenGL的“当前激活”的“Context”
        EAGLContext.setCurrent(context)
        /// 注意: 激活深度检测,设置深度检测一定要放在设置上一句的下面, 要不然context还没有激活
        glEnable(GLenum(GL_DEPTH_TEST))
    }
    
    fileprivate func setupBuffer() {
        
        var vertices: UnsafeMutablePointer<Float>? // 顶点
        var texCoord: UnsafeMutablePointer<Float>? // 纹理
        var indices: UnsafeMutablePointer<UInt16>? // 索引
        var numVertices: Int32? = 0
        /// 编译C文件 获取顶点/纹理/索引
        numIndices = Int(GLuint(initSphere(Int32(sphereSliceNum), Float(sphereRadius), &vertices, &texCoord, &indices, &numVertices!)))
        
        /// 加载顶点索引数据
        glGenBuffers(1, &vertexIndicesBufferID) // 申请内存
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vertexIndicesBufferID) // 将命名的缓冲对象绑定到指定的类型上去
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), numIndices * MemoryLayout<GLushort>.size, indices, GLenum(GL_STATIC_DRAW))
        
        /// 加载顶点坐标数据
        glGenBuffers(1, &vertexBufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Int(numVertices!) * 3 * MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW))
        
        /// 激活顶点位置属性
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 3), nil)
        
        // 纹理
        glGenBuffers(1, &vertexTexCoordID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexTexCoordID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Int(numVertices!) * 2 * MemoryLayout<GLfloat>.size, texCoord, GLenum(GL_DYNAMIC_DRAW))
        glEnableVertexAttribArray(GLuint(GLint(GLKVertexAttrib.texCoord0.rawValue)))
        glVertexAttribPointer(GLuint(GLint(GLKVertexAttrib.texCoord0.rawValue)), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 2), nil)
    }
    
    fileprivate func runningTexture(_ filePath: String) {
        
        // 获取图片纹理信息
        textureInfo = try? GLKTextureLoader.texture(withContentsOfFile: filePath, options: [GLKTextureLoaderOriginBottomLeft: NSNumber(booleanLiteral: true)])
        
        effect = GLKBaseEffect()
        effect?.texture2d0.enabled = GLboolean(GL_TRUE)
        effect?.texture2d0.name = textureInfo!.name
    }
    
    fileprivate func startDeviceMotion() {
        
        /**设置初始坐标系, 并开始监控
         CMAttitudeReferenceFrameXArbitraryCorrectedZVertical: 描述的参考系默认设备平放(垂直于Z轴)，在X轴上取任意值。实际上当你开始刚开始对设备进行motion更新的时候X轴就被固定了。不过这里还使用了罗盘来对陀螺仪的测量数据做了误差修正
         使用pull形式获取数据
         */
        motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical)
        modelViewMatrix = GLKMatrix4Identity
    }
    
    fileprivate func addPanGestureRecognizer() {
        
        self.addGestureRecognizer(pan)
    }
    
    fileprivate func addDisplayLink() {
        
        let displayLink = CADisplayLink.init(target: self, selector: #selector(displayAction))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    @objc fileprivate func displayAction() {
        
        display()
    }
    
    // MARK: - 监听方法
    @objc fileprivate func panActionDidClick(_ pan: UIPanGestureRecognizer) {
        
        let point: CGPoint = pan.translation(in: self)
        panX += point.x
        panY += point.y
        // 变换完后设置0
        pan.setTranslation(CGPoint.zero, in: self)
    }
    
    // MARK: - 懒加载
    /// 陀螺仪
    fileprivate lazy var motionManager: CMMotionManager = {
        
        let motion = CMMotionManager()
        motion.deviceMotionUpdateInterval = 1.0 / 60.0 // 更新间隔
        motion.showsDeviceMovementDisplay = true
        return motion
    }()
    /// 拖拽手势
    fileprivate lazy var pan: UIPanGestureRecognizer = {
        
        let p = UIPanGestureRecognizer()
        p.addTarget(self, action: #selector(MMPhotoView.panActionDidClick(_:)))
        return p
    }()
}






































