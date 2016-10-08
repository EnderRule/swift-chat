//
//  SAPhotoLoader.swift
//  SIMChat
//
//  Created by sagesse on 10/5/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

public protocol SAPhotoLoaderType: class {
    
    var size: CGSize? { get }
    var image: UIImage? { get }
    var orientation: UIImageOrientation? { get }
    
    weak var delegate: SAPhotoLoaderDelegate? { set get }
    
    func requestImage()
    func cancelRequestImage()
    
    func rotation(_ orientation: UIImageOrientation)
}

public protocol SAPhotoLoaderDelegate: class {
    
    func loader(_ loader: SAPhotoLoaderType, didChangeSize size: CGSize?)
    func loader(_ loader: SAPhotoLoaderType, didChangeImage image: UIImage?)
    
    func loader(didStart loader: SAPhotoLoader)
    func loader(didComplate loader: SAPhotoLoader, image: UIImage?)
}

open class SAPhotoLoader: NSObject, SAPhotoLoaderType {
    
    open var image: UIImage?
    
    open var size: CGSize? 
    open var orientation: UIImageOrientation?
    
    open let photo: SAPhoto
    open weak var delegate: SAPhotoLoaderDelegate?
    
    open func rotation(_ orientation: UIImageOrientation) {
        guard let image = image, image.imageOrientation != orientation else {
            return
        }
        self.image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: orientation)
        self.size = self.image?.size
        self.orientation = self.image?.imageOrientation
    }
    open func requestImage() {
        //_logger.trace()
        
        delegate?.loader(didStart: self)
        
        // 检查是不是己经加载过了
        guard !_loaded else {
            delegate?.loader(didComplate: self, image: self.image)
            return
        }
        // 检查是不是正在加载中, 如果是正在加载中等待事件
        guard _requestId == nil else {
            return
        }
        
        let options = PHImageRequestOptions()
        
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
//        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
//        imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
//        imageRequestOptions.progressHandler = phProgressHandler;
        
        _requestId = SAPhotoLibrary.shared.requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { [weak self] in
            self?.logger.trace()
            
            guard let ss = self else {
                return
            }
            let oldSize = ss.size
            let oldImage = ss.image
            
            ss.size = $0?.size
            ss.image = $0
            ss.orientation = $0?.imageOrientation
            
            let isError = ($1?[PHImageErrorKey] as? NSError) != nil
            let isCancel = ($1?[PHImageCancelledKey] as? Int) != nil
            let isDegraded = ($1?[PHImageResultIsDegradedKey] as? Int) == 1
            let isLoaded = isError || isCancel || !isDegraded
            
            // 检查有没有加载成功
            guard !isLoaded else {
                ss._requestId = nil
                ss._loaded = true
                ss.delegate?.loader(didComplate: ss, image: ss.image)
                return
            }
            // 如果图片大小发生改变通知用户
            if oldSize != ss.size {
                ss.delegate?.loader(ss, didChangeSize: ss.size)
            }
            // 如果图片发生改变通知用户
            if oldImage != ss.image {
                ss.delegate?.loader(ss, didChangeImage: ss.image)
            }
        }
    }
    open func cancelRequestImage() {
        //_logger.trace()
    }
    
    public init(photo: SAPhoto) {
        self.photo = photo
        super.init()
    }
    
    private var _requestId: PHImageRequestID?
    private var _loaded: Bool = false
}
