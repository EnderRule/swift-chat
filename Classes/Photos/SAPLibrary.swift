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
    
    
    public func imageItem(with asset: SAPAsset, size: CGSize) -> SAPProgressiveItem? {
        _logger.trace("\(asset.identifier) - \(size)")
        
        let key = asset.identifier
        let name = "\(Int(size.width))x\(Int(size.height)).png"
        // 读取缓存
        if let item = _allCaches[key]?[name]?.object {
            return item
        }
        let item = SAPProgressiveItem(size: size)
        let options = PHImageRequestOptions()
        
        item.progress = 1 // 默认是1, 只有在progressHandler回调的时候才会出现进度
        item.content = _cachedImage(with: asset, size: size) // 获取最接近的一张图片
        
        //options.deliveryMode = .highQualityFormat //.fastFormat//opportunistic
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.progressHandler = { [weak item](progress, error, stop, info) in
            _SAPhotoQueueTasksAdd(.main) {
                item?.progress = progress
            }
        }
        // 创建缓冲池
        if _allCaches.index(forKey: asset.identifier) == nil {
            _allCaches[key] = [:]
        }
        _allCaches[key]?[name] = SAPWKObject(object: item)
        // 异步请求
        _queue.async {
            print("request", asset.identifier, size)
            self._requestImage(asset, size, .aspectFill, options) { (img, info) in
                // 读取字典
                let isError = (info?[PHImageErrorKey] as? NSError) != nil
                let isCancel = (info?[PHImageCancelledKey] as? Int) != nil
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Int) == 1
                let isInClound = (info?[PHImageResultIsInCloudKey] as? Int) == 1
                
                let os = (item.content as? UIImage)?.size ?? .zero
                let ns = img?.size ?? .zero
                // 新加载的图片必须比当前的图片大
                print("respond", asset.identifier, size, img)
                guard ns.width >= os.width && ns.height >= os.height else {
                    return
                }
                // 添加任务到主线程
                _SAPhotoQueueTasksAdd(.main) { [weak item] in
                    guard item != nil else {
                        return
                    }
                    let os = (item?.content as? UIImage)?.size ?? .zero
                    let ns = img?.size ?? .zero
                    // 新加载的图片必须比当前的图片大
                    if ns.width >= os.width && ns.height >= os.height {
                        // 更新内容
                        item?.content = img
                    }
                    // 检查是否己经载完成
                    if isError || isCancel || !isDegraded {
                        // 更新进度
                        item?.progress = 1
                    } else if isInClound {
                        // 图片还在在iClound上, 重置进度
                        guard (item?.progress ?? 0) > 0.999999 else {
                            return
                        }
                        item?.progress = 0
                    }
                }
            }
        }
        
        return item
    }
    public func playerItem(with asset: SAPAsset) -> SAPProgressiveItem? {
        //_logger.trace()
        
        let item = SAPProgressiveItem(size: asset.size)
        let options = PHVideoRequestOptions()
        
        options.isNetworkAccessAllowed = true
        
        _requestPlayerItem(asset, options) { (pitem, info) in
            item.content = pitem
            item.progress = 1
        }
        
        return item
    }
    
    private func _cachedImage(with asset: SAPAsset, size: CGSize) -> UIImage? {
        // is cache?
        guard let caches = _allCaches[asset.identifier] else {
            return nil
        }
        var image: UIImage?
        
        // 查找
        caches.forEach {
            guard let item = $1.object else {
                return
            }
            // 当前找到的最符合的图片大小
            let crs = image?.size ?? .zero
            // 当前item的图片大小
            let cis = (item.content as? UIImage)?.size ?? .zero
            // 必须小于或者等于size
            guard (cis.width <= size.width && cis.height <= size.height) || (size == SAPhotoMaximumSize) else {
                return
            }
            // 必须大于当前的图片
            guard (cis.width >= crs.width && cis.height >= crs.height) else {
                return
            }
            image = item.content as? UIImage
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
    private lazy var _allCaches: [String: [String: SAPWKObject<SAPProgressiveItem>]] = [:]
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

private var _SAPhotoQueueTasks: Array<() -> Void>?
private func _SAPhotoQueueTasksAdd(_ queue: DispatchQueue, task: @escaping () -> Void) {
    // 合并任务, 减少线程唤醒次数
    objc_sync_enter(SAPLibrary.self)
    
    var isstart = _SAPhotoQueueTasks != nil
    if _SAPhotoQueueTasks == nil {
        _SAPhotoQueueTasks = [task]
    } else {
        _SAPhotoQueueTasks?.append(task)
    }
    
    objc_sync_exit(SAPLibrary.self)
    
    guard !isstart else {
        return
    }
    // 开启线程
    queue.async {
        objc_sync_enter(SAPLibrary.self)
        let tasks = _SAPhotoQueueTasks
        _SAPhotoQueueTasks = nil
        objc_sync_exit(SAPLibrary.self)
        
        tasks?.forEach {
            $0()
        }
    }
}


public let SAPhotoMaximumSize = PHImageManagerMaximumSize


