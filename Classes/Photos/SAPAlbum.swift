//
//  SAPAlbum.swift
//  SAC
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos


public class SAPAlbum: NSObject {
    
    public let collection: PHAssetCollection
    
    public var title: String? {
        return collection.localizedTitle
    }
    public var identifier: String {
        return collection.localIdentifier
    }
    
    public var type: PHAssetCollectionType {
        return collection.assetCollectionType
    }
    public var subtype: PHAssetCollectionSubtype {
        return collection.assetCollectionSubtype
    }
    
    public override var hash: Int {
        return identifier.hash
    }
    public override var hashValue: Int {
        return identifier.hashValue
    }
    public override var description: String {
        return collection.description
    }
    
    public var count: Int {
        return fetchResult?.count ?? 0
    }
    public var fetchResult: PHFetchResult<PHAsset>? {
        if let result = _fetchResult {
            return result
        }
        let result = PHAsset.fetchAssets(in: collection, options: nil)
        _fetchResult = result
        return result
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let collection = object as? SAPAlbum else {
            return false
        }
        return identifier == collection.identifier
    }
    
    public func clearCache() {
        //_logger.trace()
        
        _fetchResult = nil
    }
    public func photos(with result: PHFetchResult<PHAsset>) -> [SAPAsset] {
        var photos: [SAPAsset] = []
        result.enumerateObjects({
            let photo = SAPAsset(asset: $0.0, album: self)
            photos.append(photo)
        })
        return photos
    }
    public func photos(with result: PHFetchResult<PHAsset>, in range: NSRange) -> [SAPAsset] {
        guard let range = range.toRange() else {
            return []
        }
        var photos: [SAPAsset] = []
        
        result.enumerateObjects(at: IndexSet(integersIn: range), options: .init(rawValue: 0), using: {
            let photo = SAPAsset(asset: $0.0, album: self)
            photos.append(photo)
        })
        
        return photos
    }
    
    /// 获取所有相册
    public static var albums: [SAPAlbum] {
        return _fetchAssetCollections()
    }
    /// 获取moment相册
    public static var momentAlbum: SAPAlbum? {
        return _fetchAssetCollections(with: .moment, subtype: .any).first
    }
    /// 获取历史相册
    public static var recentlyAlbum: SAPAlbum? {
        return _fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded).first
    }
    
    
    public init(collection: PHAssetCollection) {
        self.collection = collection
        super.init()
    }
    deinit {
        // album销毁， 表明关联的photo己经被释放
        SAPLibrary.shared.clearInvaildCaches()
    }
    
    private var _fetchResult: PHFetchResult<PHAsset>?
}

// MARK: - Fetch

extension SAPAlbum {
    
    fileprivate static func _fetchAssetCollections() -> [SAPAlbum] {
        var types: [(PHAssetCollectionType, PHAssetCollectionSubtype)] = []
        
        // smart album -> user
        types.append((.smartAlbum, .smartAlbumUserLibrary))
        types.append((.smartAlbum, .smartAlbumFavorites))
        types.append((.smartAlbum, .smartAlbumGeneric))
            
        // smart album -> recently
        types.append((.smartAlbum, .smartAlbumRecentlyAdded))
            
        // smart album -> video
        types.append((.smartAlbum, .smartAlbumPanoramas))
        types.append((.smartAlbum, .smartAlbumVideos))
        types.append((.smartAlbum, .smartAlbumSlomoVideos))
        types.append((.smartAlbum, .smartAlbumTimelapses))
        
        // smart album -> screenshots
        if #available(iOS 9.0, *) { 
            types.append((.smartAlbum, .smartAlbumScreenshots))
            //types.append((.smartAlbum, .smartAlbumSelfPortraits))
        }
        
        // album -> share
        types.append((.album, .albumMyPhotoStream))
        types.append((.album, .albumCloudShared))
        
        // album -> user
        types.append((.album, .albumRegular))
        types.append((.album, .albumSyncedAlbum))
        types.append((.album, .albumImported))
        types.append((.album, .albumSyncedFaces))
        
        return types.reduce([]) {
            $0 + _fetchAssetCollections(with: $1.0, subtype: $1.1)
        }
    }
    fileprivate static func _fetchAssetCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions? = nil) -> [SAPAlbum] {
        var albums: [SAPAlbum] = []
        PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil).enumerateObjects({ 
            albums.append(SAPAlbum(collection: $0.0))
        })
        return albums
    }
}
