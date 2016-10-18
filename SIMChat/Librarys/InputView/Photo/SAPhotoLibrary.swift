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

public class SAPhotoLibrary: NSObject {
   
    
    public func isExists(of photo: SAPhoto) -> Bool {
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
    
    public func image(with photo: SAPhoto, size: CGSize) -> UIImage? {
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
            let os = image.size
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
    public func imageForAlmost(with photo: SAPhoto, size: CGSize) -> UIImage? {
        //_logger.trace()
        
        guard let caches = _allCaches[photo.identifier] else {
            return nil
        }
        var image: UIImage?
        
        // 查找
        caches.forEach {
            guard let img = $1.object as? SAPhotoProgressiveableImage else {
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
    
    public func data(with photo: SAPhoto,  resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) {
        SAPhotoLibrary.shared._requestImageData(photo, nil, resultHandler: resultHandler)
    }
    
    
    func clearInvaildCaches() {
        DispatchQueue.main.async {
            self._clearInvaildCachesOnMainThread()
        }
    }
    
    private func _clearInvaildCachesOnMainThread() {
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
    
//    public func requestImage(for photo: SAPhoto, targetSize: CGSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
//        let im = PHCachingImageManager.default()
//        return im.requestImage(for: photo.asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
//    }
//    public static func requestImageData(for photo: SAPhoto, options: PHImageRequestOptions? = nil, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void) {
//        let im = PHCachingImageManager.default()
//        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
//    }
    
    private func _requestImage(_ photo: SAPhoto, _ size: CGSize, _ contentMode: PHImageContentMode, _ options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestImage(for: photo.asset, targetSize: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
    private func _requestImageData(_ photo: SAPhoto, _ options: PHImageRequestOptions?, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
    }
    
//- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *photosBytes))completion
//{
//    __block NSInteger dataLength = 0;
//    
//    __block NSInteger count = photos.count;
//    
//    __weak typeof(self) weakSelf = self;
//    for (int i = 0; i < photos.count; i++) {
//        ZLSelectPhotoModel *model = photos[i];
//        [[PHCachingImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            dataLength += imageData.length;
//            count--;
//            if (count <= 0) {
//            if (completion) {
//            completion([strongSelf transformDataLength:dataLength]);
//            }
//            }
//            }];
//    }
//    }
//    
//    - (NSString *)transformDataLength:(NSInteger)dataLength {
//        NSString *bytes = @"";
//        if (dataLength >= 0.1 * (1024 * 1024)) {
//            bytes = [NSString stringWithFormat:@"%.1fM",dataLength/1024/1024.0];
//        } else if (dataLength >= 1024) {
//            bytes = [NSString stringWithFormat:@"%.0fK",dataLength/1024.0];
//        } else {
//            bytes = [NSString stringWithFormat:@"%zdB",dataLength];
//        }
//        return bytes;
//}
    
//        // Asynchronous image preheating (aka caching), note that only image sources are cached (no crop or exact resize is ever done on them at the time of caching, only at the time of delivery when applicable).
//        // The options values shall exactly match the options values used in loading methods. If two or more caching requests are done on the same asset using different options or different targetSize the first
//        // caching request will have precedence (until it is stopped)
    public func startCachingImages(for assets: [SAPhoto], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        let ass = assets.map {
            return $0.asset
        }
        im.startCachingImages(for: ass, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    public func stopCachingImages(for assets: [SAPhoto], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
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
    
    public static var shared: SAPhotoLibrary = {
        let lib = SAPhotoLibrary()
        PHPhotoLibrary.shared().register(lib)
        return lib
    }()
    
    private lazy var _allCaches: [String: [String: SAPhotoWeakObject<UIImage>]] = [:]
}

extension SAPhotoLibrary: PHPhotoLibraryChangeObserver {
    // This callback is invoked on an arbitrary serial queue. If you need this to be handled on a specific queue, you should redispatch appropriately
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        // ??
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
//    let ratio = CGFloat(photo.pixelWidth) / CGFloat(photo.pixelHeight)
//    let width = CGFloat(id + 1) * 16
//    let height = round(width / ratio)
    return size
    //return CGSize(width: width, height: height)
}


public let SAPhotoMaximumSize = PHImageManagerMaximumSize

