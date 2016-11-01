//
//  SAPLibrary.swift
//  SAC
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

public class SAPLibrary: NSObject {
   
    
    public func isExists(of photo: SAPAsset) -> Bool {
        return PHAsset.fetchAssets(withLocalIdentifiers: [photo.identifier], options: nil).count != 0
    }
    
    public func register(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.register(observer)
    }
    public func unregisterChangeObserver(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.unregisterChangeObserver(observer)
    }
    
    public func image(with photo: SAPAsset, size: CGSize) -> UIImage? {
        //_logger.trace()
        
        let name = "\(Int(size.width))x\(Int(size.height)).png"
        // 读取缓存
        if let image = _allCaches[photo.identifier]?[name]?.object {
            return image
        }
        let image = SAPProgressiveableImage()
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
        
        _allCaches[photo.identifier]?[name] = SAPWKObject(object: image)
        _queue.async {
            self._requestImage(photo, size, .aspectFill, options) { (img, info) in
                let os = image.size
                let ns = img?.size ?? .zero
                
                DispatchQueue.main.async {
                if ns.width >= os.width && ns.height >= os.height {
                    image.content = img
                    
                    // // 检查是否己经完成了任务
                    // let isError = (info?[PHImageErrorKey] as? NSError) != nil
                    // let isCancel = (info?[PHImageCancelledKey] as? Int) != nil
                    // let isDegraded = (info?[PHImageResultIsDegradedKey] as? Int) == 1
                    // let isLoaded = isError || isCancel || !isDegraded
                }
                }
            }
        }
        
        return image
    }
    public func imageForAlmost(with photo: SAPAsset, size: CGSize) -> UIImage? {
        //_logger.trace()
        
        guard let caches = _allCaches[photo.identifier] else {
            return nil
        }
        var image: UIImage?
        
        // 查找
        caches.forEach {
            guard let img = $1.object as? SAPProgressiveableImage else {
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
            
            image = img.content as? UIImage
        }
        
        return image
    }
    
    public func data(with photo: SAPAsset, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) {
        //_logger.trace(photo.identifier)
        
        _requestImageData(photo, nil, resultHandler: resultHandler)
    }
    
    public func playerItem(with photo: SAPAsset, resultHandler: @escaping (AVPlayerItem?, [AnyHashable : Any]?) -> Void) {
        
        //@interface PHVideoRequestOptions : NSObject
        //@property (nonatomic, assign, getter=isNetworkAccessAllowed) BOOL networkAccessAllowed;
        //@property (nonatomic, assign) PHVideoRequestOptionsVersion version;
        //@property (nonatomic, assign) PHVideoRequestOptionsDeliveryMode deliveryMode;
        //@property (nonatomic, copy, nullable) PHAssetVideoProgressHandler progressHandler;
        //@end
        
        _requestPlayerItem(photo, nil, resultHandler: resultHandler)
    }
    
    
    func clearInvaildCaches() {
        guard !_needsClearCaches else {
            return
        }
        //_logger.trace()
        
        _needsClearCaches = true
        
        DispatchQueue.main.async {
            self._needsClearCaches = false
            self._clearCachesOnMainThread()
        }
    }
    
    private func _clearCachesOnMainThread() {
        //_logger.trace()
        
        _allCaches.keys.forEach { key in
            let keys: [String]? = _allCaches[key]?.flatMap {
                if $1.object == nil {
                    return $0
                }
                return nil
            }
            guard keys?.count != _allCaches[key]?.count else {
                _allCaches.removeValue(forKey: key)
                return
            }
            keys?.forEach {
                _ = _allCaches[key]?.removeValue(forKey: $0)
            }
        }
    }
    
//    public func requestImage(for photo: SAPAsset, targetSize: CGSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
//        let im = PHCachingImageManager.default()
//        return im.requestImage(for: photo.asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
//    }
//    public static func requestImageData(for photo: SAPAsset, options: PHImageRequestOptions? = nil, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void) {
//        let im = PHCachingImageManager.default()
//        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
//    }
    
    private func _requestImage(_ photo: SAPAsset, _ size: CGSize, _ contentMode: PHImageContentMode, _ options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestImage(for: photo.asset, targetSize: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
    private func _requestPlayerItem(_ photo: SAPAsset, _ options: PHVideoRequestOptions?, resultHandler: @escaping (AVPlayerItem?, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestPlayerItem(forVideo: photo.asset, options: options, resultHandler: resultHandler)
    }
    
    private func _requestImageData(_ photo: SAPAsset, _ options: PHImageRequestOptions?, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
    }
    
//        // Asynchronous image preheating (aka caching), note that only image sources are cached (no crop or exact resize is ever done on them at the time of caching, only at the time of delivery when applicable).
//        // The options values shall exactly match the options values used in loading methods. If two or more caching requests are done on the see asset using different options or different targetSize the first
//        // caching request will have precedence (until it is stopped)
    public func startCachingImages(for assets: [SAPAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        let ass = assets.map {
            return $0.asset
        }
        im.startCachingImages(for: ass, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    public func stopCachingImages(for assets: [SAPAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        let ass = assets.map {
            return $0.asset
        }
        im.stopCachingImages(for: ass, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    public func stopCachingImagesForAllAssets() {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        im.stopCachingImagesForAllAssets()
    }
    
    //public static func cancelImageRequest(_ requestID: PHImageRequestID) { }
    
    public func requestAuthorization(clouser: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { permission in
            DispatchQueue.main.async {
                clouser(permission == .authorized)
            }
        }
    }
    
    public static var shared: SAPLibrary = {
        let lib = SAPLibrary()
        PHPhotoLibrary.shared().register(lib)
        return lib
    }()
    
    private var _needsClearCaches: Bool = false

    private lazy var _queue: DispatchQueue = DispatchQueue(label: "SAPhotoImageLoadQueue")
    private lazy var _allCaches: [String: [String: SAPWKObject<UIImage>]] = [:]
}

extension SAPLibrary: PHPhotoLibraryChangeObserver {
    // This callback is invoked on an arbitrary serial queue. If you need this to be handled on a specific queue, you should redispatch appropriately
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        // ??
    }
}

private func _SAPhotoResouceId(_ photo: SAPAsset, size: CGSize) -> UInt {
    guard size != SAPhotoMaximumSize else {
        return UInt.max
    }
    return UInt(size.width) / 16
}
private func _SAPhotoResouceSize(_ photo: SAPAsset, size: CGSize) -> CGSize {
    let id = _SAPhotoResouceId(photo, size: size)
    guard id != .max else {
        return SAPhotoMaximumSize
    }
//    let ratio = CGFloat(photo.pixelWidth) / CGFloat(photo.pixelHeight)
//    let width = CGFloat(id + 1) * 16
//    let height = round(width / ratio)
    return size
    //return CGSize(width: width, height: height)
}


public let SAPhotoMaximumSize = PHImageManagerMaximumSize

