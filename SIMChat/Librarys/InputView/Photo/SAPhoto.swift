//
//  SAPhoto.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

public class SAPhoto: NSObject {
    
    public var identifier: String {
        return asset.localIdentifier
    }
    
    public var pixelWidth: Int { 
        return asset.pixelWidth
    }
    public var pixelHeight: Int { 
        return asset.pixelHeight
    }

    public var creationDate: Date? { 
        return asset.creationDate
    }
    public var modificationDate: Date? { 
        return asset.modificationDate
    }
    
    public var mediaType: PHAssetMediaType { 
        return asset.mediaType
    }
    public var mediaSubtypes: PHAssetMediaSubtype { 
        return asset.mediaSubtypes
    }

    public var location: CLLocation? { 
        return asset.location
    }
    
    public var duration: TimeInterval { 
        return asset.duration
    }
    
    public var isHidden: Bool { 
        return asset.isHidden
    }
    public var isFavorite: Bool { 
        return asset.isFavorite
    }
    
    public var burstIdentifier: String? { 
        return asset.burstIdentifier
    }
    public var burstSelectionTypes: PHAssetBurstSelectionType { 
        return asset.burstSelectionTypes
    }
    
    public var representsBurst: Bool { 
        return asset.representsBurst
    }
    
    public override var hash: Int {
        return identifier.hash
    }
    public override var hashValue: Int {
        return identifier.hashValue
    }
    public override var description: String {
        return asset.description
    }
    
    public var size: CGSize {
        return CGSize(width: pixelWidth, height: pixelHeight)
    }
    public var image: UIImage? {
        return image(with: SAPhotoMaximumSize)
    }
    
    public func size(with orientation: UIImageOrientation) -> CGSize {
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            return CGSize(width: pixelHeight, height: pixelWidth)
            
        case .up, .upMirrored, .down, .downMirrored:
            return CGSize(width: pixelWidth, height: pixelHeight)
        }
    }
    public func image(with size: CGSize) -> UIImage? {
        return SAPhotoLibrary.shared.image(with: self, size: size)
    }
    
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let photo = object as? SAPhoto else {
            return false
        }
        return identifier == photo.identifier
    }
    
    public var asset: PHAsset
    
    public weak var album: SAPhotoAlbum?
    
    public init(asset: PHAsset) {
        self.asset = asset
        super.init()
    }
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
