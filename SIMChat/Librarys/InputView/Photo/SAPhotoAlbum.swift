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
    
    open static func reloadData() {
        
        _albums?.forEach {
            $0._photos = nil
        }
        _albums = nil
        _recentlyAlbum = nil
    }
    
    open var title: String? {
        return collection.localizedTitle
    }
    open var identifier: String {
        return collection.localIdentifier
    }
    
    open var type: PHAssetCollectionType {
        return collection.assetCollectionType
    }
    open var subtype: PHAssetCollectionSubtype {
        return collection.assetCollectionSubtype
    }
    
    open override var description: String {
        return collection.description
    }
    
    open var photos: [SAPhoto] {
        if let photos = _photos {
            return photos
        }
        let photos = _loadPhotos()
        _photos = photos
        return photos
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
    
    open var collection: PHAssetCollection
    open var result: PHFetchResult<PHAsset>?
    
    fileprivate var _photos: [SAPhoto]?
    
    private static var _albums: [SAPhotoAlbum]?
    private static var _recentlyAlbum: SAPhotoAlbum??
    
    public init(collection: PHAssetCollection) {
        self.collection = collection
        super.init()
    }
}

// MARK: - Fetch

extension SAPhotoAlbum {
    
    func photos(with result: PHFetchResult<PHAsset>) -> [SAPhoto] {
        var photos: [SAPhoto] = []
        self.result = result
        self.result?.enumerateObjects({
            let photo = SAPhoto(asset: $0.0)
            photo.album = self
            photos.append(photo)
        })
        return photos
    }
    
    
    func _loadPhotos() -> [SAPhoto] {
        var photos: [SAPhoto] = []
        result = PHAsset.fetchAssets(in: collection, options: nil)
        result?.enumerateObjects({
            let photo = SAPhoto(asset: $0.0)
            photo.album = self
            photos.append(photo)
        })
        return photos
    }
    
    static func _loadAlbums() -> [SAPhotoAlbum] {
        var albums: [SAPhotoAlbum] = []
        
        PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil).enumerateObjects({
            albums.append(SAPhotoAlbum(collection: $0.0))
        })
        PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil).enumerateObjects({
            albums.append(SAPhotoAlbum(collection: $0.0))
        })
        
        return albums.sorted { 
            ($0.title ?? "") < ($1.title ?? "")
        }
    }
}
