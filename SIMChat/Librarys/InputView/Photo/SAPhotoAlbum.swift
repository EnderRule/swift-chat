//
//  SAPhotoAlbum.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos


open class SAPhotoAlbum: NSObject {
    
    open var title: String? {
        return _collection.localizedTitle
    }
    open var identifier: String {
        return _collection.localIdentifier
    }
    
    open var type: PHAssetCollectionType {
        return _collection.assetCollectionType
    }
    open var subtype: PHAssetCollectionSubtype {
        return _collection.assetCollectionSubtype
    }
    
    open override var description: String {
        return _collection.description
    }
    
    open static var albums: [SAPhotoAlbum] {
        if let albums = _albums {
            return albums
        }
        let albums = _loadAlbums()
        _albums = albums
        return albums
    }
    open static var recentlyAlbum: SAPhotoAlbum? {
        if let album = _recentlyAlbum {
            return album
        }
        var album: SAPhotoAlbum?
        albums.forEach {
            guard $0.subtype == .smartAlbumRecentlyAdded else {
                return
            }
            album = $0
        }
        _recentlyAlbum = album
        return album
    }
    
    private static var _albums: [SAPhotoAlbum]?
    private static var _recentlyAlbum: SAPhotoAlbum??
    
    private var _collection: PHAssetCollection
    
    init(collection: PHAssetCollection) {
        _collection = collection
        super.init()
    }
}

// MARK: - Fetch

private extension SAPhotoAlbum {
    
    class func _loadAlbums() -> [SAPhotoAlbum] {
        var albums: [SAPhotoAlbum] = []
        
        PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil).enumerateObjects({
            albums.append(_makeAlbum(with: $0.0))
        })
        PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil).enumerateObjects({
            albums.append(_makeAlbum(with: $0.0))
        })
        
        return albums.sorted { 
            ($0.title ?? "") < ($1.title ?? "")
        }
    }
    class func _makeAlbum(with collection: PHAssetCollection) -> SAPhotoAlbum {
        let album = SAPhotoAlbum(collection: collection)
        return album
    }
}
