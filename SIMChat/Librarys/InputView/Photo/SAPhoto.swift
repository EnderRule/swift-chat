//
//  SAPhoto.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

open class SAPhoto: NSObject {
    
    open var identifier: String {
        return asset.localIdentifier
    }
    
    open var pixelWidth: Int { 
        return asset.pixelWidth
    }
    open var pixelHeight: Int { 
        return asset.pixelHeight
    }

    open var creationDate: Date? { 
        return asset.creationDate
    }
    open var modificationDate: Date? { 
        return asset.modificationDate
    }
    
    open var mediaType: PHAssetMediaType { 
        return asset.mediaType
    }
    open var mediaSubtypes: PHAssetMediaSubtype { 
        return asset.mediaSubtypes
    }

    open var location: CLLocation? { 
        return asset.location
    }
    
    open var duration: TimeInterval { 
        return asset.duration
    }
    
    open var isHidden: Bool { 
        return asset.isHidden
    }
    open var isFavorite: Bool { 
        return asset.isFavorite
    }
    
    open var burstIdentifier: String? { 
        return asset.burstIdentifier
    }
    open var burstSelectionTypes: PHAssetBurstSelectionType { 
        return asset.burstSelectionTypes
    }
    
    open var representsBurst: Bool { 
        return asset.representsBurst
    }
    
    open override var hash: Int {
        return identifier.hash
    }
    open override var hashValue: Int {
        return identifier.hashValue
    }
    open override var description: String {
        return asset.description
    }
    open override func isEqual(_ object: Any?) -> Bool {
        guard let photo = object as? SAPhoto else {
            return false
        }
        return identifier == photo.identifier
    }
    
    open var asset: PHAsset
    
    open weak var album: SAPhotoAlbum?
    
    public init(asset: PHAsset) {
        self.asset = asset
        super.init()
    }
}

extension SAPhoto: SAPhotoProgressiveable {
    
    open var size: CGSize {
        return CGSize(width: pixelWidth, height: pixelHeight)
    }
    open func size(with orientation: UIImageOrientation) -> CGSize {
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            return CGSize(width: pixelHeight, height: pixelWidth)
            
        case .up, .upMirrored, .down, .downMirrored:
            return CGSize(width: pixelWidth, height: pixelHeight)
        }
    }
    
    open var image: UIImage? {
        return image(with: SAPhotoMaximumSize)
    }
    open func image(with size: CGSize) -> UIImage? {
        return SAPhotoLibrary.shared.image(with: self, size: size)
    }
   
//    public func imageTask(_ targetSize: CGSize) -> SAPhotoTask {
//        var size = targetSize
//        
//        if size != SAPhotoMaximumSize {
//            size.width = targetSize.width * UIScreen.main.scale
//            size.height = targetSize.height * UIScreen.main.scale
//        }
//        
//        return SAPhotoLibrary.shared.imageTask(with: self, targetSize: size)
//    }
    
//    public func requestImage(_ targetSize: CGSize, resultHandler: @escaping (SAPhotoProgressiveable, UIImage?) -> Void) {
//        let options = PHImageRequestOptions()
////        
////        //progressiveable
////        
//////        _options.resizeMode = PHImageRequestOptionsResizeModeExact;
//////        _options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
//        options.deliveryMode = .opportunistic
//        options.resizeMode = .fast
//        options.isNetworkAccessAllowed = true
////        
//        var size = targetSize
//        
//        if size != SAPhotoMaximumSize {
//            size.width = targetSize.width * UIScreen.main.scale
//            size.height = targetSize.height * UIScreen.main.scale
//        }
//        
////        let size = PHImageManagerMaximumSize
////            //CGSize(width: CGFloat(photo.pixelWidth), height: CGFloat(photo.pixelHeight))
////        
//////        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
//////        imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
//////        imageRequestOptions.progressHandler = phProgressHandler;
////        
//        _ = SAPhotoLibrary.shared.requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: options) { [weak self] in
//            
//            _ = $1
//            //print($1)
//            
//            print("\(size) => \($0)")
//            
//            guard let ss = self else {
//                return
//            }
//            resultHandler(ss, $0)
//            
////            observer.progressiveable(ss, didChangeImage: $0)
//            
////            self?.logger.trace()
////            
////            let oldSize = ss.size
////            let oldImage = ss.image
////            
////            ss.size = $0?.size
////            ss.image = $0
////            ss.orientation = $0?.imageOrientation
////            
////            let isError = ($1?[PHImageErrorKey] as? NSError) != nil
////            let isCancel = ($1?[PHImageCancelledKey] as? Int) != nil
////            let isDegraded = ($1?[PHImageResultIsDegradedKey] as? Int) == 1
////            let isLoaded = isError || isCancel || !isDegraded
////            
////            // 检查有没有加载成功
////            guard !isLoaded else {
////                ss._requestId = nil
////                ss._loaded = true
////                ss.delegate?.loader(didComplate: ss, image: ss.image)
////                return
////            }
////            // 如果图片大小发生改变通知用户
////            if oldSize != ss.size {
////                ss.delegate?.loader(ss, didChangeSize: ss.size)
////            }
////            // 如果图片发生改变通知用户
////            if oldImage != ss.image {
////                ss.delegate?.loader(ss, didChangeImage: ss.image)
////            }
//        }
//    }
//    public func cancelRequestImage() {
//    }
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
