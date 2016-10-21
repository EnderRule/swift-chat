//
//  SAPhotoBadgeView.swift
//  SIMChat
//
//  Created by sagesse on 21/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal enum SAPhotoBadge {
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
    
    init(photo: SAPhoto) {
        
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
internal enum SAPhotoBadgeSytle {
    case normal
    case small
}

internal class SAPhotoBadgeView: UIView {
    
    var style: SAPhotoBadgeSytle = .normal
    
    var badge: SAPhotoBadge = .normal {
        didSet {
            guard oldValue != badge else {
                return // no change
            }
            if badge == .normal {
                
                _leftView?.removeFromSuperview()
                _leftView = nil
                
                _backgroundLayer?.removeFromSuperlayer()
                _backgroundLayer = nil
                
            } else if _leftView == nil {
                
                let view = UIImageView()
                let backgroundLayer = CAGradientLayer()
                
                view.contentMode = .scaleAspectFit
                
                addSubview(view)
                
                backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0)
                backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1)
//                backgroundLayer.locations = [
//                    0.2,
//                    0.8,
//                ]
                backgroundLayer.colors = [
                    UIColor(white: 0, alpha: 0.0).cgColor,
                    UIColor(white: 0, alpha: 0.6).cgColor,
                ]
                
                layer.insertSublayer(backgroundLayer, at: 0)
                
                _leftView = view
                _backgroundLayer = backgroundLayer
                
            }
            
            _leftView?.image = _image(with: badge)?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var duration: TimeInterval? {
        didSet {
            guard let duration = duration else {
                _rightView?.removeFromSuperview()
                _rightView = nil
                return
            }
            if _rightView == nil {
                
                let view = UILabel()
                
                view.font = UIFont.systemFont(ofSize: 12)
                view.textColor = UIColor.white
                view.textAlignment = .right
                
                addSubview(view)
                
                _rightView = view
            }
            _rightView?.text = SAPhotoFormatDuration(duration)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _leftView?.sizeToFit()
        _rightView?.sizeToFit()
        _backgroundLayer?.frame = bounds
        
        if let view = _leftView {
            var nframe = view.frame
            
            nframe.size.height = min(nframe.height, bounds.height - 4)
            
            nframe.origin.x = 4//style == .small ? 2 : 4
            nframe.origin.y = (bounds.height - nframe.height) / 2
            
            view.frame = nframe
        }
        if let view = _rightView {
            var nframe = view.frame
            
            nframe.origin.x = (bounds.width - nframe.width) - 4
            nframe.origin.y = (bounds.height - nframe.height) / 2
            
            view.frame = nframe
        }
    }
    
    func _image(with badge: SAPhotoBadge) -> UIImage? {
        
        switch badge {
        case .favorites:
            return UIImage(named: "photo_badge_favorites")
            
        case .panoramas:
            return UIImage(named: "photo_badge_panorama")
            
        case .videos:
            if style == .small {
                return UIImage(named: "photo_badge_video_small")
            }
            return UIImage(named: "photo_badge_video")
            
        case .slomo:
            if style == .small {
                return UIImage(named: "photo_badge_slomo_small")
            }
            return UIImage(named: "photo_badge_slomo")
            
        case .timelapses:
            if style == .small {
                return UIImage(named: "photo_badge_timelapse_small")
            }
            return UIImage(named: "photo_badge_timelapse")
            
        case .screenshots:
            return UIImage(named: "photo_badge_screenshots")
            
        case .normal:
            return nil
        }
    }
    
    private var _leftView: UIImageView?
    private var _rightView: UILabel?
    private var _backgroundLayer: CAGradientLayer?
    
    convenience init(style: SAPhotoBadgeSytle) {
        self.init()
        self.style = style
    }
}
