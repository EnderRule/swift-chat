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
