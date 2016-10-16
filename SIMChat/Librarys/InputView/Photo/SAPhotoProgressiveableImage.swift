//
//  SAPhotoProgressiveableImage.swift
//  SIMChat
//
//  Created by sagesse on 10/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 支持渐进式更新的图片
///
public class SAPhotoProgressiveableImage: UIImage, SAPhotoProgressiveable {
   
    /// 真正的内容
    public var content: UIImage? {
        set {
            _content = newValue?.withOrientation(_orientation)
            _notify(_content)
        }
        get {
            return _content 
        }
    }
    /// 图片的大小
    public override var size: CGSize {
        return content?.size ?? .zero
    }
    public override var imageOrientation: UIImageOrientation {
        return _orientation
    }
    
    ///
    /// 添加监听者
    ///
    /// - Parameter observer: 监听者, 这是weak
    ///
    public func addObserver(_ observer: SAPhotoProgressiveableObserver) {
        _observers.add(observer)
    }
    ///
    /// 移除监听者(如果有)
    ///
    /// - Parameter observer: 监听者
    ///
    public func removeObserver(_ observer: SAPhotoProgressiveableObserver) {
        _observers.remove(observer)
    }
    
    /// 复制
    private func _copy() -> SAPhotoProgressiveableImage {
        let image = SAPhotoProgressiveableImage()
        
        image._parent = self
        image._content = _content
        image._orientation = _orientation
        
        // 添加
        _replicaes.add(image)
        
        return image
    }
    /// 通知变更
    private func _notify(_ image: UIImage?) {
        //_logger.trace()
        
        _observers.allObjects.forEach {
            $0.progressiveable(self, didChangeImage: image)
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
        let image = _parent?._copy() ?? _copy()
        
        image._orientation = orientation
        image._content = _content?.withOrientation(orientation)
        
        return image
    }
    
    public override class func initialize() {
        _SAInputExchangeSelector(UIImageView.self, "image", "sa_image")
        _SAInputExchangeSelector(UIImageView.self, "setImage:", "sa_setImage:")
    }
    
    private var _parent: SAPhotoProgressiveableImage?  // 如果不强引用, 当parent释放后就获取不到通知了
    
    private var _orientation: UIImageOrientation = .up
    private var _content: UIImage?
    
    private let _observers = NSHashTable<SAPhotoProgressiveableObserver>.weakObjects()
    private let _replicaes = NSHashTable<SAPhotoProgressiveableImage>.weakObjects()
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
extension UIImageView: SAPhotoProgressiveableObserver {
    
    public func progressiveable(_ progressiveable: SAPhotoProgressiveable, didChangeImage image: UIImage?) {
        sa_setImage(image)
    }
    
    private dynamic func sa_setImage(_ newValue: UIImage?) {
        guard let image = newValue as? SAPhotoProgressiveableImage else {
            sa_progressiveImage = nil
            sa_setImage(newValue)
            return
        }
        sa_progressiveImage = image
        sa_setImage(image.content)
    }
    private dynamic func sa_image() -> UIImage? {
        guard let image = sa_progressiveImage else {
            return sa_image()
        }
        return image
    }
    
    private dynamic var sa_progressiveImage: SAPhotoProgressiveableImage? {
        set {
            let oldValue = sa_progressiveImage
            guard oldValue !== newValue else {
                return // no change
            }
            oldValue?.removeObserver(self)
            newValue?.addObserver(self)
            
            return objc_setAssociatedObject(self, &_UIImageViewProgressiveImage, newValue, .OBJC_ASSOCIATION_RETAIN) 
        }
        get { 
            return objc_getAssociatedObject(self, &_UIImageViewProgressiveImage) as? SAPhotoProgressiveableImage 
        }
    }
}

private var _UIImageViewProgressiveImage = "_UIImageViewProgressiveImage"
