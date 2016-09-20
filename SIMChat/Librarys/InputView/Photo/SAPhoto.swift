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
    
    open override var description: String {
        return asset.description
    }
    
    internal var asset: PHAsset
    
    public init(asset: PHAsset) {
        self.asset = asset
        super.init()
    }
}
