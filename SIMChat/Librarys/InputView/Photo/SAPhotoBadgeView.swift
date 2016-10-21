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
}
internal enum SAPhotoBadgeExtra {
    
    case none
    case text(String)
    case icon(UIImage?)
    
}

internal class SAPhotoBadgeView: UIView {
    
    var badge: SAPhotoBadge = .normal {
        didSet {
            if badge == .normal {
                
                _leftView?.removeFromSuperview()
                _leftView = nil
                
                _backgroundLayer?.removeFromSuperlayer()
                _backgroundLayer = nil
                
            } else if _leftView == nil {
                
                let view = UIImageView()
                let backgroundLayer = CAGradientLayer()
                
                view.contentMode = .center
                
                addSubview(view)
                
                backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0)
                backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1)
                backgroundLayer.locations = [
                    0.2,
                    0.8,
                ]
                backgroundLayer.colors = [
                    UIColor(white: 0, alpha: 0.0).cgColor,
                    UIColor(white: 0, alpha: 0.6).cgColor,
                ]
                
                layer.insertSublayer(backgroundLayer, at: 0)
                
                _leftView = view
                _backgroundLayer = backgroundLayer
                
            }
            
            _leftView?.image = _image(with: badge)?.withRenderingMode(.alwaysTemplate)
            
//            switch badge {
//            case .normal:
//
//                _backgroundLayer?.removeFromSuperlayer()
//                _backgroundLayer = nil
//                
//            default:
//            }
            
        }
    }
    
    var badgeExtra: SAPhotoBadgeExtra = .none
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        _leftView?.sizeToFit()
        _backgroundLayer?.frame = bounds
        
        if let view = _leftView {
            var nframe = view.frame
            
            nframe.origin.x = 4
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
            return UIImage(named: "photo_badge_video")
            
        case .slomo:
            return UIImage(named: "photo_badge_slomo")
            
        case .timelapses:
            return UIImage(named: "photo_badge_timelapse")
            
        case .screenshots:
            return UIImage(named: "photo_badge_screenshots")
            
        case .normal:
            return nil
        }
    }
    
    private var _leftView: UIImageView?
    private var _rightView: UIImageView?
    private var _backgroundLayer: CAGradientLayer?
}
