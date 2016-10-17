//
//  SAPhotoLibrary.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

public enum SAPhotoStatus {
   
    case notPermission
    case notData
    case notError
}

internal struct SAPhotoWeakObject<T: AnyObject>: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: SAPhotoWeakObject<T>, rhs: SAPhotoWeakObject<T>) -> Bool {
        return lhs.object === rhs.object
    }

    weak var object: T?
}

open class SAPhotoLibrary: NSObject {
   
    
    open func isExists(of photo: SAPhoto) -> Bool {
        return PHAsset.fetchAssets(withLocalIdentifiers: [photo.identifier], options: nil).count != 0
    }
    
    open func register(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.register(observer)
    }
    open func unregisterChangeObserver(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.unregisterChangeObserver(observer)
    }
    
    open func image(with photo: SAPhoto, size: CGSize) -> UIImage? {
        //_logger.trace()
        
        let name = "\(Int(size.width))x\(Int(size.height)).png"
        // 读取缓存
        if let image = _allCaches[photo.identifier]?[name]?.object {
            return image
        }
        let image = SAPhotoProgressiveableImage()
        let options = PHImageRequestOptions()
        
        // 获取最接近的一张图片
        image.content = imageForAlmost(with: photo, size: size)
        
        //options.deliveryMode = .highQualityFormat //.fastFormat//opportunistic
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        // 创建缓冲池
        if _allCaches.index(forKey: photo.identifier) == nil {
            _allCaches[photo.identifier] = [:]
        }
        
        _allCaches[photo.identifier]?[name] = SAPhotoWeakObject(object: image)
        _requestImage(photo, size, .aspectFill, options) { (img, info) in
            let os = image.content?.size ?? .zero
            let ns = img?.size ?? .zero
            
            if ns.width >= os.width && ns.height >= os.height {
                image.content = img
                
                // // 检查是否己经完成了任务
                // let isError = (info?[PHImageErrorKey] as? NSError) != nil
                // let isCancel = (info?[PHImageCancelledKey] as? Int) != nil
                // let isDegraded = (info?[PHImageResultIsDegradedKey] as? Int) == 1
                // let isLoaded = isError || isCancel || !isDegraded
            }
        }
        
        return image
    }
    open func imageForAlmost(with photo: SAPhoto, size: CGSize) -> UIImage? {
        //_logger.trace()
        
        guard let caches = _allCaches[photo.identifier] else {
            return nil
        }
        var image: UIImage?
        
        // 查找
        caches.forEach {
            guard let img = ($1.object as? SAPhotoProgressiveableImage)?.content else {
                return
            }
            let os = image?.size ?? .zero
            let ns = img.size
            // 必须小于或者等于size
            guard (ns.width <= size.width && ns.height <= size.height) || (size == SAPhotoMaximumSize) else {
                return
            }
            // 必须大于当前的图片
            guard (ns.width >= os.width && ns.height >= os.height) else {
                return
            }
            
            image = img
        }
        
        return image
    }
    
    
    func clearInvaildCaches() {
        _logger.trace()
        
//        var caches: [String: SAPhotoWeakObject<UIImage>] = [:]
//        _allCaches.forEach {
//            guard let _ = $1.object else {
//                return
//            }
//            caches[$0] = $1
//        }
//        _allCaches = caches
    }
    
    open func requestImage(for photo: SAPhoto, targetSize: CGSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let im = PHCachingImageManager.default()
        return im.requestImage(for: photo.asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    open static func requestImageData(for photo: SAPhoto, options: PHImageRequestOptions? = nil, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void) {
        let im = PHCachingImageManager.default()
        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
    }
    
    private func _requestImage(_ photo: SAPhoto, _ size: CGSize, _ contentMode: PHImageContentMode, _ options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestImage(for: photo.asset, targetSize: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
//        // Asynchronous image preheating (aka caching), note that only image sources are cached (no crop or exact resize is ever done on them at the time of caching, only at the time of delivery when applicable).
//        // The options values shall exactly match the options values used in loading methods. If two or more caching requests are done on the same asset using different options or different targetSize the first
//        // caching request will have precedence (until it is stopped)
    open func startCachingImages(for assets: [SAPhoto], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        let ass = assets.map {
            return $0.asset
        }
        im.startCachingImages(for: ass, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    open func stopCachingImages(for assets: [SAPhoto], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        let ass = assets.map {
            return $0.asset
        }
        im.stopCachingImages(for: ass, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    open func stopCachingImagesForAllAssets() {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        im.stopCachingImagesForAllAssets()
    }
    
    //open static func cancelImageRequest(_ requestID: PHImageRequestID) { }
    
    open func requestAuthorization(clouser: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { permission in
            DispatchQueue.main.async {
                clouser(permission == .authorized)
            }
        }
    }
    
    open static var shared: SAPhotoLibrary = {
        let lib = SAPhotoLibrary()
        PHPhotoLibrary.shared().register(lib)
        return lib
    }()
    
    private lazy var _allCaches: [String: [String: SAPhotoWeakObject<UIImage>]] = [:]
}

extension SAPhotoLibrary: PHPhotoLibraryChangeObserver {
    // This callback is invoked on an arbitrary serial queue. If you need this to be handled on a specific queue, you should redispatch appropriately
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        SAPhotoAlbum.clearCaches()
    }
}

private func _SAPhotoResouceId(_ photo: SAPhoto, size: CGSize) -> UInt {
    guard size != SAPhotoMaximumSize else {
        return UInt.max
    }
    return UInt(size.width) / 16
}
private func _SAPhotoResouceSize(_ photo: SAPhoto, size: CGSize) -> CGSize {
    let id = _SAPhotoResouceId(photo, size: size)
    guard id != .max else {
        return SAPhotoMaximumSize
    }
    let ratio = CGFloat(photo.pixelWidth) / CGFloat(photo.pixelHeight)
    let width = CGFloat(id + 1) * 16
    let height = round(width / ratio)

    return size
    //return CGSize(width: width, height: height)
}


public let SAPhotoMaximumSize = PHImageManagerMaximumSize

