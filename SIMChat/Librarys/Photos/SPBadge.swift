//
//  SPBadge.swift
//  SPhotos
//
//  Created by sagesse on 31/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal enum SPBadge {
    case normal
    case favorites
    case panoramas
    
    // video
    case videos
    case slomo
    case timelapses
    
    case screenshots
    
    init(collectionSubtype: PHAssetCollectionSubtype) {
        switch collectionSubtype {
        case .smartAlbumFavorites:      self = .favorites
        case .smartAlbumPanoramas:      self = .panoramas
            
        case .smartAlbumVideos:         self = .videos
        case .smartAlbumSlomoVideos:    self = .slomo
        case .smartAlbumTimelapses:     self = .timelapses
            
        case .smartAlbumScreenshots:    self = .screenshots
        default:                        self = .normal
        }
    }
    
    init(photo: SPAsset) {
        
        if photo.mediaSubtypes.contains(.photoPanorama) {
            self = .panoramas
            return
        }
        if photo.mediaSubtypes.contains(.videoTimelapse) {
            self = .timelapses
            return
        }
        if photo.mediaSubtypes.contains(.videoHighFrameRate) {
            self = .slomo
            return
        }
        if photo.mediaType == .video {
            self = .videos
            return
        }
        
        self = .normal
    }
}

internal enum SPBadgeSytle {
    case normal
    case small
}
