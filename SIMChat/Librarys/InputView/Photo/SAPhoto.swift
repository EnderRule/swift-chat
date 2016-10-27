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
    
    public var data: Data?
    public func data(with handler: @escaping (Data?) -> Void)  {
        if let data = data {
            return handler(data)
        }
        return SAPhotoLibrary.shared.data(with: self) { [weak self](data, dataUTI, orientation, info) in
            self?.data = data
            handler(data)
        }
    }
    
    public weak var playerItem: AVPlayerItem?
    public func playerItem(with handler: @escaping (AVPlayerItem?) -> Void) {
        if let playerItem = playerItem {
            return handler(playerItem)
        }
        SAPhotoLibrary.shared.playerItem(with: self) { [weak self](item, info) in
            self?.playerItem = item
            DispatchQueue.main.async {
                handler(item)
            }
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let photo = object as? SAPhoto else {
            return false
        }
        return identifier == photo.identifier
    }
    
    public let asset: PHAsset
    public let album: SAPhotoAlbum
    
    public init(asset: PHAsset, album: SAPhotoAlbum) {
        self.asset = asset
        self.album = album
        super.init()
    }
}

internal func SAPhotoFormatDuration(_ duration: TimeInterval) -> String {
    let s = Int(duration) % 60
    let m = Int(duration / 60)
    return String(format: "%02zd:%02zd", m, s)
}

internal func SAPhotoFormatBytesLenght(_ len: Int) -> String {
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
