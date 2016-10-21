//
//  SAPhotoAlbumStackView.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoAlbumStackView: UIView, SAPhotoProgressiveableObserver {
    
    var album: SAPhotoAlbum? {
        didSet {
            guard let newValue = album else {
                return
            }
            guard let newResult = newValue.fetchResult else {
                // is empty
                _updateIcon(.any)
                _updatePhotos([])
                return 
            }
            let range = NSMakeRange(max(newValue.count - 3, 0), min(3, newValue.count))
            
            _updateIcon(newValue.subtype)
            _updatePhotos(newValue.photos(with: newResult, in: range).reversed())
        }
    }
    
    func progressiveable(_ progressiveable: SAPhotoProgressiveable, didChangeContent content: Any?) {
        guard let index = _images.index(where: { $1 === progressiveable }) else {
            return
        }
        let key = _images[index].key
        guard key < _imageLayers.count else {
            return
        }
        _imageLayers[key].contents = (content as? UIImage)?.cgImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let h = bounds.height
        let w = bounds.width
        let sw: CGFloat = 4
        
        _imageLayers.enumerated().forEach {
            let fidx = CGFloat($0)
            var nframe = CGRect(x: 0, y: 0, width: w - sw * fidx, height: h - sw * fidx)
            nframe.origin.x = (w - nframe.width) / 2
            nframe.origin.y = (0 - (sw / 2) * fidx)
            $1.frame = nframe
        }
    }
    
    private func _updateIcon(_ type: PHAssetCollectionSubtype) {
        _logger.trace()
        
        //type == .smartAlbumFavorites
        
        //type == .smartAlbumPanoramas
        //type == .smartAlbumVideos
        //type == .smartAlbumSlomoVideos
        //type == .smartAlbumTimelapses
        
        //type == .smartAlbumScreenshots
        
        
//    // PHAssetCollectionTypeAlbum regular subtypes
//    PHAssetCollectionSubtypeAlbumRegular         = 2,
//    PHAssetCollectionSubtypeAlbumSyncedEvent     = 3,
//    PHAssetCollectionSubtypeAlbumSyncedFaces     = 4,
//    PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5,
//    PHAssetCollectionSubtypeAlbumImported        = 6,
//    
//    // PHAssetCollectionTypeAlbum shared subtypes
//    PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,
//    PHAssetCollectionSubtypeAlbumCloudShared     = 101,
//    
//    // PHAssetCollectionTypeSmartAlbum subtypes
//    PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,
//    PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,
//    PHAssetCollectionSubtypeSmartAlbumVideos     = 202,
//    PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,
//    PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,
//    PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,
//    PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,
//    PHAssetCollectionSubtypeSmartAlbumBursts     = 207,
//    PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,
//    PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,
//    PHAssetCollectionSubtypeSmartAlbumSelfPortraits PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 210,
//    PHAssetCollectionSubtypeSmartAlbumScreenshots PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 211,
    }
    private func _updatePhotos(_ photos: [SAPhoto]) {
        //_logger.trace(photos.count)
        
        // 更新内容
        var size = bounds.size
        
        size.width *= UIScreen.main.scale
        size.height *= UIScreen.main.scale
        
        _imageLayers.enumerated().forEach { 
            guard !photos.isEmpty else {
                // 这是一个空的相册
                $0.element.isHidden = false
                $0.element.backgroundColor = UIColor(white: 0.9, alpha: 1).cgColor
                
                _setImage(nil, at: $0.offset)
                
                return
            }
            guard $0.offset < photos.count else {
                // 这个相册并没有3张图片
                $0.element.isHidden = true
                $0.element.contentsGravity = kCAGravityResizeAspectFill
                
                return _setImage(nil, at: $0.offset)
            }
            let photo = photos[$0.offset]
            
            $0.element.isHidden = false
            $0.element.backgroundColor = UIColor.white.cgColor
            
            _setImage(photo.image(with: size) as? SAPhotoProgressiveableImage, at: $0.offset)
        }
        
        if photos.isEmpty {
            
            _iconImageView.frame = bounds
            _iconImageView.image = UIImage(named: "photo_icon_empty_album")?.withRenderingMode(.alwaysTemplate)
            _iconImageView.contentMode = .center
            _iconImageView.tintColor = UIColor.gray
            
            addSubview(_iconImageView)
            
        } else if _iconImageView.superview != nil {
            
            _iconImageView.image = nil
            _iconImageView.removeFromSuperview()
        }
    }
    
    private func _setImage(_ newValue: SAPhotoProgressiveableImage?, at index: Int) {
        
        let oldValue = _images[index] ?? nil
        guard oldValue != newValue else {
            return
        }
        
        oldValue?.removeObserver(self)
        newValue?.addObserver(self)
        
        _images[index] = newValue
        _imageLayers[index].contents = (newValue?.content as? UIImage)?.cgImage
    }
    
    private func _init() {
        //_logger.trace()
        
        _imageLayers = (0 ..< 3).map { index in
            let il = CALayer()
            
            il.masksToBounds = true
            il.borderWidth = 0.5
            il.borderColor = UIColor.white.cgColor
            il.contentsGravity = kCAGravityResizeAspectFill
            
            layer.insertSublayer(il, at: 0)
            
            return il
        }
        
        _iconImageView.frame = bounds
        _iconImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private lazy var _images: [Int: SAPhotoProgressiveableImage?] = [:]
    private lazy var _imageLayers: [CALayer] = []
    
    private lazy var _iconImageView: UIImageView = UIImageView()
}
