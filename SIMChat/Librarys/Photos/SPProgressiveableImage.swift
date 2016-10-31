//
//  SPProgressiveableImage.swift
//  SIMChat
//
//  Created by sagesse on 10/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 支持渐进式更新的图片
///
public class SPProgressiveableImage: UIImage, SPProgressiveable {
    
    /// 真正的内容
    public var content: Any? {
        set {
            if let newValue = newValue as? UIImage {
                _content = newValue.withOrientation(_orientation)
            }
            _notify(_content)
        }
        get {
            return _content
        }
    }
    
    public override var size: CGSize {
        return _content?.size ?? .zero
    }
    public override var imageOrientation: UIImageOrientation {
        return _orientation
    }
    
    ///
    /// 添加监听者
    ///
    /// - Parameter observer: 监听者, 这是weak
    ///
    public func addObserver(_ observer: SPProgressiveableObserver) {
        _observers.add(observer)
    }
    ///
    /// 移除监听者(如果有)
    ///
    /// - Parameter observer: 监听者
    ///
    public func removeObserver(_ observer: SPProgressiveableObserver) {
        _observers.remove(observer)
    }
    
    
    private func _mutableCopy() -> SPProgressiveableImage {
        let image = SPProgressiveableImage()
        
        image._parent = self
        image._content = _content
        image._orientation = _orientation
        
        // 添加
        _replicaes.add(image)
        
        return image
    }
    
    private func _notify(_ image: UIImage?) {
        //_logger.trace()
        
        _observers.allObjects.forEach {
            $0.progressiveable(self, didChangeContent: image)
        }
        _replicaes.allObjects.forEach { 
            $0.content = image
        }
    }
    
    deinit {
        _parent = nil
    }
    
    public override func withOrientation(_ orientation: UIImageOrientation) -> UIImage? {
        guard imageOrientation != orientation else {
            return self
        }
        let image = _parent?._mutableCopy() ?? _mutableCopy()
        
        image._orientation = orientation
        image._content = _content?.withOrientation(orientation)
        
        return image
    }
    
    public override class func initialize() {
        
        let m1 = class_getInstanceMethod(UIImageView.self, #selector(getter: UIImageView.image))
        let m2 = class_getInstanceMethod(UIImageView.self, #selector(UIImageView.sm_image))
        
        let m3 = class_getInstanceMethod(UIImageView.self, #selector(setter: UIImageView.image))
        let m4 = class_getInstanceMethod(UIImageView.self, #selector(UIImageView.sm_setImage(_:)))
        
        method_exchangeImplementations(m1, m2)
        method_exchangeImplementations(m3, m4)
    }
    
    private var _parent: SPProgressiveableImage?  // 如果不强引用, 当parent释放后就获取不到通知了
    
    private var _orientation: UIImageOrientation = .up
    private var _content: UIImage?
    
    private let _observers = NSHashTable<SPProgressiveableObserver>.weakObjects()
    private let _replicaes = NSHashTable<SPProgressiveableImage>.weakObjects()
}

///
/// 使UIImage支持方向切换
///
extension UIImage {
    
    public func withOrientation(_ orientation: UIImageOrientation) -> UIImage? {
        guard imageOrientation != orientation else {
            return self
        }
        if let image = cgImage {
            return UIImage(cgImage: image, scale: scale, orientation: orientation)
        }
        if let image = ciImage {
            return UIImage(ciImage: image, scale: scale, orientation: orientation)
        }
        return nil
    }
}

///
/// 使UIImageView支持渐进式更新
///
extension UIImageView: SPProgressiveableObserver {
 
    ///
    /// 内容发生改变
    ///
    public func progressiveable(_ progressiveable: SPProgressiveable, didChangeContent content: Any?) {
        sm_setImage(content as? UIImage)
    }
    
    internal dynamic func sm_setImage(_ newValue: UIImage?) {
        guard let image = newValue as? SPProgressiveableImage else {
            sm_progressiveImage = nil
            sm_setImage(newValue)
            return
        }
        sm_progressiveImage = image
        sm_setImage(image.content as? UIImage)
    }
    internal dynamic func sm_image() -> UIImage? {
        guard let image = sm_progressiveImage else {
            return sm_image()
        }
        return image
    }
    
    internal dynamic var sm_progressiveImage: SPProgressiveableImage? {
        set {
            let oldValue = sm_progressiveImage
            guard oldValue !== newValue else {
                return // no change
            }
            oldValue?.removeObserver(self)
            newValue?.addObserver(self)
            
            return objc_setAssociatedObject(self, &_UIImageViewProgressiveImage, newValue, .OBJC_ASSOCIATION_RETAIN) 
        }
        get { 
            return objc_getAssociatedObject(self, &_UIImageViewProgressiveImage) as? SPProgressiveableImage 
        }
    }
}

private var _UIImageViewProgressiveImage = "_UIImageViewProgressiveImage"
