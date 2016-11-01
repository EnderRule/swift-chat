//
//  SAPAsset.swift
//  SAPhotos
//
//  Created by sagesse on 31/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

public class SAPAsset: NSObject {
    
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
        return SAPLibrary.shared.image(with: self, size: size)
    }
    
    public var data: Data?
    public func data(with handler: @escaping (Data?) -> Void)  {
        if let data = data {
            return handler(data)
        }
        return SAPLibrary.shared.data(with: self) { [weak self](data, dataUTI, orientation, info) in
            self?.data = data
            handler(data)
        }
    }
    
    public weak var playerItem: AVPlayerItem?
    public func playerItem(with handler: @escaping (AVPlayerItem?) -> Void) {
        if let playerItem = playerItem {
            return handler(playerItem)
        }
        SAPLibrary.shared.playerItem(with: self) { [weak self](item, info) in
            self?.playerItem = item
            DispatchQueue.main.async {
                handler(item)
            }
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let photo = object as? SAPAsset else {
            return false
        }
        return identifier == photo.identifier
    }
    
    public let asset: PHAsset
    public let album: SAPAlbum
    
    public init(asset: PHAsset, album: SAPAlbum) {
        self.asset = asset
        self.album = album
        super.init()
    }
}

internal func SAPStringForDuration(_ duration: TimeInterval) -> String {
    let s = Int(duration) % 60
    let m = Int(duration / 60)
    return String(format: "%02zd:%02zd", m, s)
}

internal func SAPStringForBytesLenght(_ len: Int) -> String {
    if len <= 999 {
        // 只显示1B-999B
        return String(format: "%zdB", len)
    }
    if len <= 999 * 1024 {
        // 只显示1k-999k
        return String(format: "%zdK", len / 1024)
    }
    return String(format: "%.1lfM", Double(len) / 1024 / 1024)
}
