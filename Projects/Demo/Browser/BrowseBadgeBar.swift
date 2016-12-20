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
        _updateVisableViewLayoutIfNeeded()
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
        
        _leftViews = leftBarItems?.map { item -> UIView in
            let view = _createView(with: item)
            addSubview(view)
            return view
        } ?? []
        _rightViews = rightBarItems?.map { item -> UIView in
            let view = _createView(with: item)
            addSubview(view)
            return view
        } ?? []
        _cacheBounds = nil
    }
    func _updateVisableViewLayoutIfNeeded() {
        guard _cacheBounds?.size != self.bounds.size else {
            return
        }
        _cacheBounds = self.bounds
        
        let sp = CGFloat(2)
        let edg = UIEdgeInsetsMake(2, 4, 2, 4)
        let bounds = UIEdgeInsetsInsetRect(self.bounds, edg)
        
        _ = _leftViews.reduce(bounds.minX) { x, view in
            var nframe = CGRect(x: x, y: bounds.minY, width: 0, height: 0)
            
            let size = view.sizeThatFits(bounds.size)
            
            nframe.size.width = size.width
            nframe.size.height = min(size.height, bounds.height)
            nframe.origin.x = x
            nframe.origin.y = bounds.minY + (bounds.height - nframe.height) / 2
            
            view.frame = nframe
            return x + nframe.width + sp
        }
        _ = _rightViews.reduce(bounds.maxX) { x, view in
            var nframe = CGRect(x: x, y: bounds.minY, width: 0, height: 0)
            
            let size = view.sizeThatFits(bounds.size)
            
            nframe.size.width = size.width
            nframe.size.height = min(size.height, bounds.height)
            nframe.origin.x = x - nframe.width
            nframe.origin.y = bounds.minY + (bounds.height - nframe.height) / 2
            
            view.frame = nframe
            return x - nframe.width - sp
        }
    }
    
    private func _createView(with item: BrowseBadgeBarItem) -> UIView {
        if let image = item.image {
            let view = UIImageView(image: image)
            return view
        }
        if let title = item.title {
            let label = UILabel()
            
            label.text = title
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12)
            //label.adjustsFontSizeToFitWidth = true
            
            return label
        }
        return UIView()
    }
    
    private var _cacheBounds: CGRect?
    private var _needUpdateVisableViews: Bool = true
    
    private lazy var _leftViews: [UIView] = []
    private lazy var _rightViews: [UIView] = []
}

