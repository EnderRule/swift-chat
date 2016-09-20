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
        return _asset.localIdentifier
    }
    
    open var pixelWidth: Int { 
        return _asset.pixelWidth
    }
    open var pixelHeight: Int { 
        return _asset.pixelHeight
    }

    open var creationDate: Date? { 
        return _asset.creationDate
    }
    open var modificationDate: Date? { 
        return _asset.modificationDate
    }
    
    open var mediaType: PHAssetMediaType { 
        return _asset.mediaType
    }
    open var mediaSubtypes: PHAssetMediaSubtype { 
        return _asset.mediaSubtypes
    }

    open var location: CLLocation? { 
        return _asset.location
    }
    
    open var duration: TimeInterval { 
        return _asset.duration
    }
    
    open var isHidden: Bool { 
        return _asset.isHidden
    }
    open var isFavorite: Bool { 
        return _asset.isFavorite
    }
    
    open var burstIdentifier: String? { 
        return _asset.burstIdentifier
    }
    open var burstSelectionTypes: PHAssetBurstSelectionType { 
        return _asset.burstSelectionTypes
    }
    
    open var representsBurst: Bool { 
        return _asset.representsBurst
    }
    
    open override var description: String {
        return _asset.description
    }
    
    private var _asset: PHAsset
    
    public init(asset: PHAsset) {
        _asset = asset
        super.init()
    }
}
