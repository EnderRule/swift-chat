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
    
    open func register(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.register(observer)
    }
    open func unregisterChangeObserver(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.unregisterChangeObserver(observer)
    }
    
    open func requestImage(for photo: SAPhoto, targetSize: CGSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestImage(for: photo.asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
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
        SAPhotoAlbum.reloadData()
    }
}

