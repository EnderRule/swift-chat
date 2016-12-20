//
//  BrowseBadgeBar.swift
//  Browser
//
//  Created by sagesse on 20/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

enum BrowseBadgeBarItemStyle {
    case custom
    
    case photosAll
    case photosBurst
    
    case photosFavorites
    case photosLastImport
    case photosPanorama
    case photosRecentlyDeleted
    case photosScreenshots
    case photosSelfies
    case photosSlomo
    case photosTimelapse
    case photosVideo
}

class BrowseBadgeBarItem {
    
    init(title: String) {
        self.title = title
    }
    init(image: UIImage) {
        self.image = image
    }
    convenience init(style: BrowseBadgeBarItemStyle) {
        self.init(image: UIImage(named: "photo_icon_thumbnail_loading")!)
    }
    
    var title: String?
    var image: UIImage?
}

class BrowseBadgeBar: UIView {
    
    var backgroundImage: UIImage?
    
    var leftBarItems: [BrowseBadgeBarItem]? {
        didSet {
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
    }
    var rightBarItems: [BrowseBadgeBarItem]? {
        didSet {
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateVisableViewsIfNeeded()
    }
    
    func _updateVisableViewsIfNeeded() {
        guard _needUpdateVisableViews else {
            return
        }
        _needUpdateVisableViews = false
        
        _leftViews.forEach { 
            $0.removeFromSuperview()
        }
        _rightViews.forEach { 
            $0.removeFromSuperview()
        }
        
        _logger.debug()
        
    }
    
    private var _needUpdateVisableViews: Bool = true
    
    private lazy var _leftViews: [UIView] = []
    private lazy var _rightViews: [UIView] = []
}


