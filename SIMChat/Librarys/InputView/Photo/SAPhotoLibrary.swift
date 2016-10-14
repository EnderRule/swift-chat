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

@objc
internal protocol SAPhotoTaskDelegate: class {
    
    @objc optional func task(_ task: SAPhotoTask, didReceive image: UIImage?)
    
    @objc optional func task(_ task: SAPhotoTask, didComplete image: UIImage?)
    @objc optional func task(_ task: SAPhotoTask, didCompleteWithError error: Error?)
    
    //    optional public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    
//    @available(iOS 7.0, *)
//    optional public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void)
//    @available(iOS 7.0, *)
//    optional public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void)
//    @available(iOS 7.0, *)
//    optional public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Swift.Void)
//    @available(iOS 7.0, *)
//    optional public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
//    @available(iOS 10.0, *)
//    optional public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
//    @available(iOS 7.0, *)
//    optional public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
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


public class SAPhotoTask: NSObject {
    
   
    func attach(_ observer: SAPhotoTaskDelegate) {
        // 如果任务己经完成, 直接回调(不用添加)
        if let image = image {
            _logger.trace("hit cache")
            observer.task?(self, didReceive: image)
            observer.task?(self, didComplete: image)
            return
        }
        // 添加到队列中
        if !observers.contains(where: { $0.object === observer }) {
            observers.append(SAPhotoWeakObject(object: observer))
        }
        // 如果任务己经开始, 返回最接近的图片, 然后等待
        if let _ = requestId {
            _logger.trace("wait task")
            observer.task?(self, didReceive: adjacentImage)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        // 如果任务没有开始, 启动任务并返回一个最接近的图片(如果有..), 然后等待
        _logger.trace("start task")
        if let image = adjacentImage {
            observer.task?(self, didReceive: image)
        }
        requestId = SAPhotoLibrary.shared.requestImage(for: photo, targetSize: size, contentMode: .aspectFill, options: options) { [weak self](image, info) in
            self?.image = image
            self?.notifi(with: image, info: info)
        }
    }
    func detach(_ observer: SAPhotoTaskDelegate) {
        // 如果所有的observer都移除了, 取消任务
        
        // 移出队列
        if let index = observers.index(where: { $0.object === observer }) {
            observers.remove(at: index)
        }
    }
    
    func notifi(with image: UIImage?, info: [AnyHashable : Any]?) {
        _logger.trace("\(size) => \(image?.size)")
        
        // 通知变更
        observers.forEach {
            $0.object?.task?(self, didReceive: image)
        }
        // 通知邻近的任务
        adjacents.forEach {
            $0.object?.notifi(with: image, info: [PHImageResultIsDegradedKey: 1])
        }
        // 检查是否己经完成了任务
        let isError = (info?[PHImageErrorKey] as? NSError) != nil
        let isCancel = (info?[PHImageCancelledKey] as? Int) != nil
        let isDegraded = (info?[PHImageResultIsDegradedKey] as? Int) == 1
        let isLoaded = isError || isCancel || !isDegraded
        guard isLoaded else {
            return
        }
        // 通知完成
        observers.forEach {
            $0.object?.task?(self, didComplete: image)
        }
        // 清除所有的任务
        observers.removeAll()
        requestId = nil
    }
    
    init(queue: SAPhotoTaskQueue, photo: SAPhoto, size: CGSize) {
        self.photo = photo
        self.size = size
        super.init()
        self.queue = queue
    }
    var photo: SAPhoto
    var size: CGSize
    
    var requestId: PHImageRequestID?
    
    weak var image: UIImage? // 请求到的图片(不缓存, 如果没有人使用了就自动释放)
    weak var adjacentImage: UIImage? {
        return adjacent?.image ?? adjacent?.adjacentImage
    }
    
    weak var queue: SAPhotoTaskQueue?
    weak var adjacent: SAPhotoTask? { // 邻近的任务
        willSet {
            if let oldValue = adjacent, let index = oldValue.adjacents.index(where: { $0.object === self }) {
                oldValue.adjacents.remove(at: index)
            }
            if let newValue = newValue, !newValue.adjacents.contains(where: { $0.object === self }) {
                newValue.adjacents.append(SAPhotoWeakObject(object: self))
            }
        }
    }
    
    // 被依赖的
    lazy var adjacents: [SAPhotoWeakObject<SAPhotoTask>] = []
    lazy var observers: [SAPhotoWeakObject<SAPhotoTaskDelegate>] = []
}

internal class SAPhotoTaskQueue: NSObject {
    
    func addTask(_ size: CGSize) -> SAPhotoTask {
        let taskId = _SAPhotoResouceId(_photo, size: size)
        // 检查任务有没有添加
        if let task = _allTasks[taskId] {
            return task
        }
        logger.trace(taskId)
        let algined = _SAPhotoResouceSize(_photo, size: size)
        let task = SAPhotoTask(queue: self, photo: _photo, size: algined)
        _allTasks[taskId] = task
        // 更新邻近的任务
        let _: SAPhotoTask? = _allTasks.keys.sorted(by: >).reduce(nil) {
            guard $1 == -1 else {
                return nil // 禁止依赖原图
            }
            let sk = _allTasks[$1]
            $0?.adjacent = sk
            return sk
        }
        return task
    }
    
    init(photo: SAPhoto) {
        _photo = photo
        super.init()
    }
    
    private var _photo: SAPhoto
    private var _allTasks: [Int: SAPhotoTask] = [:]
}

open class SAPhotoLibrary: NSObject {
   
    //PHPhotoLibraryChangeObserver
    
//    open class PHPhotoLibrary : NSObject {
//
//        
//        open class func shared() -> PHPhotoLibrary
//        
//        
//        open class func authorizationStatus() -> PHAuthorizationStatus
//        
//        open class func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Swift.Void)
//        
//        
//        // handlers are invoked on an arbitrary serial queue
//        // Nesting change requests will throw an exception
//        open func performChanges(_ changeBlock: @escaping () -> Swift.Void, completionHandler: (@escaping (Bool, Error?) -> Swift.Void)? = nil)
//        
//        open func performChangesAndWait(_ changeBlock: @escaping () -> Swift.Void) throws
//        
//        
//        open func register(_ observer: PHPhotoLibraryChangeObserver)
//        
//        open func unregisterChangeObserver(_ observer: PHPhotoLibraryChangeObserver)
//    }
    
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
    
    
    func addTask(_ task: SAPhotoTask) {
    }
    func removeTask(_ task: SAPhotoTask) {
    }
    
    private var _allTask: [String: SAPhotoTask] = [:]
    
    
//    func cache(_ size: CGSize) -> SAPhotoCache? {
//        return nil
//    }
//    func cache(_ size: CGSize, image: UIImage?) {
//    }
    
    
//    func align(_ size: CGSize) -> CGSize {
//    }
    
    private lazy var _allQueues: [String: SAPhotoTaskQueue] = [:]
    
    
    func imageTask(with photo: SAPhoto, targetSize: CGSize) -> SAPhotoTask {
        // 获取任务队列
        let queue = _allQueues[photo.identifier] ?? {
            let queue = SAPhotoTaskQueue(photo: photo)
            _allQueues[photo.identifier] = queue
            return queue
        }()
        // 向任务队列添加任务
        return queue.addTask(targetSize)
    }
    
    
    
//    func imageInfoTask(with photo: SAPhoto) -> SAPhotoTask {
//        
//    }
    
    
    open func requestImage(for photo: SAPhoto, targetSize: CGSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let im = PHCachingImageManager.default()
        return im.requestImage(for: photo.asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    open static func requestImageData(for photo: SAPhoto, options: PHImageRequestOptions? = nil, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void) {
        let im = PHCachingImageManager.default()
        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
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
}

extension SAPhotoLibrary: PHPhotoLibraryChangeObserver {
    // This callback is invoked on an arbitrary serial queue. If you need this to be handled on a specific queue, you should redispatch appropriately
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        SAPhotoAlbum.clearCaches()
    }
}


private func _SAPhotoResouceId(_ photo: SAPhoto, size: CGSize) -> Int {
    guard size != SAPhotoMaximumSize else {
        return -1
    }
    if size.width >= CGFloat(photo.pixelWidth) || size.height >= CGFloat(photo.pixelHeight) {
        return -1
    }
    return Int(size.width / 16)
}
private func _SAPhotoResouceSize(_ photo: SAPhoto, size: CGSize) -> CGSize {
    let id = _SAPhotoResouceId(photo, size: size)
    guard id != -1 else {
        return SAPhotoMaximumSize
    }
    let w = round(CGFloat(id + 1) * 16)
    let h = round(CGFloat(photo.pixelWidth) / CGFloat(photo.pixelHeight) * w)
    if w >= CGFloat(photo.pixelWidth) || h >= CGFloat(photo.pixelHeight) {
        return SAPhotoMaximumSize
    }
    return CGSize(width: w, height: h)
}


public let SAPhotoMaximumSize = PHImageManagerMaximumSize

