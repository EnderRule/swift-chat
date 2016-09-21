//
//  SAPhotoLibrary.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

open class SAPhotoLibrary: NSObject {
    
    open static func requestImage(for photo: SAPhoto, targetSize: CGSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        let im = PHImageManager.default()
        im.requestImage(for: photo.asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    open static func requestImageData(for photo: SAPhoto, options: PHImageRequestOptions? = nil, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void) {
        let im = PHImageManager.default()
        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
    }
    
    //open static func cancelImageRequest(_ requestID: PHImageRequestID) { }
    
    open static func requestAuthorization(clouser: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization {
            clouser($0 == .authorized)
        }
    }
}
