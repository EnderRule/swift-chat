//
//  SAPhotoContent.swift
//  SIMChat
//
//  Created by sagesse on 10/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoContent: NSObject, SAPhotoProgressiveable {
    
    open var imageOrientation: UIImageOrientation = .up
    open var imageSize: CGSize {
        switch imageOrientation {
        case .up, 
             .upMirrored, 
             .down, 
             .downMirrored:
            return CGSize(width: _photo.pixelWidth, height: _photo.pixelHeight)
            
        case .left, 
             .leftMirrored, 
             .right, 
             .rightMirrored:
            return CGSize(width: _photo.pixelHeight, height: _photo.pixelWidth)
        }
    }
    open func image(observer: SAPhotoProgressiveObserver, size: CGSize) {
        
        let options = PHImageRequestOptions()
//        
//        //progressiveable
//        
////        _options.resizeMode = PHImageRequestOptionsResizeModeExact;
////        _options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
//        
//        let size = PHImageManagerMaximumSize
//            //CGSize(width: CGFloat(photo.pixelWidth), height: CGFloat(photo.pixelHeight))
//        
////        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
////        imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
////        imageRequestOptions.progressHandler = phProgressHandler;
//        
        _ = SAPhotoLibrary.shared.requestImage(for: _photo, targetSize: size, contentMode: .aspectFill, options: options) { [weak self] in
            
            print($1)
            
            guard let ss = self else {
                return
            }
            observer.progressiveable(ss, didChangeImage: $0)
            
//            self?.logger.trace()
//            
//            let oldSize = ss.size
//            let oldImage = ss.image
//            
//            ss.size = $0?.size
//            ss.image = $0
//            ss.orientation = $0?.imageOrientation
//            
//            let isError = ($1?[PHImageErrorKey] as? NSError) != nil
//            let isCancel = ($1?[PHImageCancelledKey] as? Int) != nil
//            let isDegraded = ($1?[PHImageResultIsDegradedKey] as? Int) == 1
//            let isLoaded = isError || isCancel || !isDegraded
//            
//            // 检查有没有加载成功
//            guard !isLoaded else {
//                ss._requestId = nil
//                ss._loaded = true
//                ss.delegate?.loader(didComplate: ss, image: ss.image)
//                return
//            }
//            // 如果图片大小发生改变通知用户
//            if oldSize != ss.size {
//                ss.delegate?.loader(ss, didChangeSize: ss.size)
//            }
//            // 如果图片发生改变通知用户
//            if oldImage != ss.image {
//                ss.delegate?.loader(ss, didChangeImage: ss.image)
//            }
        }
    }
    
    init(photo: SAPhoto) {
        super.init()
        _photo = photo
    }
    
    private weak var _photo: SAPhoto! // 不持有photo, content的生命周期必须小于photo
}
