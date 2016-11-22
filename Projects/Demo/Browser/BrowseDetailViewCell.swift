//
//  BrowseDetailViewCell.swift
//  Browser
//
//  Created by sagesse on 11/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func withOrientation(_ orientation: UIImageOrientation) -> UIImage? {
        guard imageOrientation != orientation else {
            return self
        }
        if let image = cgImage {
            return UIImage(cgImage: image, scale: scale, orientation: orientation)
        }
        if let image = ciImage {
            return UIImage(ciImage: image, scale: scale, orientation: orientation)
        }
        return nil
    }
}

class BrowseDetailViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    var asset: Browseable? {
        willSet {
            guard asset !== newValue else {
                return
            }
            detailView.backgroundColor = newValue?.backgroundColor
            detailView.image = newValue?.browseImage?.withOrientation(orientation)
            containterView.contentSize = newValue?.browseContentSize ?? .zero
            containterView.zoom(to: bounds, with: orientation, animated: false)
            //containterView.setZoomScale(containterView.maximumZoomScale, animated: false)
        }
    }
    
    var orientation: UIImageOrientation = .up
    
    lazy var detailView: UIImageView = UIImageView()
    lazy var containterView: BrowseContainterView = BrowseContainterView()
    lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    weak var delegate: BrowseDetailViewDelegate?
    
    
    override var contentView: UIView {
        return containterView
    }
    
    dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: detailView)
        
        DispatchQueue.main.async {
            let containterView = self.containterView
            if containterView.zoomScale != containterView.minimumZoomScale {
                containterView.setZoomScale(containterView.minimumZoomScale, at: location, animated: true)
            } else {
                containterView.setZoomScale(containterView.maximumZoomScale, at: location, animated: true)
            }
        }
    }
    
    private func _commonInit() {
        
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        containterView.frame = bounds
        containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containterView.delegate = self
        containterView.addSubview(detailView)
        containterView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        super.addSubview(containterView)
    }
}

extension BrowseDetailViewCell: BrowseContainterViewDelegate {
   
    func viewForZooming(in containterView: BrowseContainterView) -> UIView? {
        return detailView
    }
    
    func containterViewShouldBeginRotationing(_ containterView: BrowseContainterView, with view: UIView?) -> Bool {
        return delegate?.browseDetailView?(self, containterView, shouldBeginRotationing: view) ?? true
    }
    
    func containterViewDidEndRotationing(_ containterView: BrowseContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        self.orientation = orientation
        self.detailView.image = detailView.image?.withOrientation(orientation)
        
        delegate?.browseDetailView?(self, containterView, didEndRotationing: view, atOrientation: orientation)
    }
}
