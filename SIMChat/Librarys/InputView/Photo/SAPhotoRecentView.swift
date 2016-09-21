//
//  SAPhotoRecentView.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
    
internal protocol SAPhotoRecentViewDelegate: NSObjectProtocol {
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, indexForSelectWith photo: SAPhoto) -> Int
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, shouldSelectFor photo: SAPhoto) -> Bool
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, didSelectFor photo: SAPhoto)
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, shouldDeselectFor photo: SAPhoto) -> Bool
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, didDeselectFor photo: SAPhoto)
}

internal class SAPhotoRecentView: UICollectionViewCell {
    
    func updateEdge() {
        _photoView.updateEdge()
    }
    func updateIndex() {
        _photoView.updateIndex()
    }
    
    var photo: SAPhoto? {
        set { return _photoView.photo = newValue }
        get { return _photoView.photo }
    }
    var isCheck: Bool {
        set { return _photoView.isSelected = newValue }
        get { return _photoView.isSelected }
    }
    
    weak var delegate: SAPhotoRecentViewDelegate?
    
    private func _init() {
        
        _photoView.frame = bounds
        _photoView.delegate = self
        _photoView.allowsSelection = true
        _photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_photoView)
    }
    
    private lazy var _photoView: SAPhotoView = SAPhotoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - SAPhotoRecentView(Forwarding)

extension SAPhotoRecentView: SAPhotoViewDelegate {
    
    func photoView(_ photoView: SAPhotoView, indexForSelectWith photo: SAPhoto) -> Int {
        return delegate?.recentView(self, photoView: photoView, indexForSelectWith: photo) ?? 0
    }
    
    func photoView(_ photoView: SAPhotoView, shouldSelectFor photo: SAPhoto) -> Bool {
        return delegate?.recentView(self, photoView: photoView, shouldSelectFor: photo) ?? true
    }
    func photoView(_ photoView: SAPhotoView, shouldDeselectFor photo: SAPhoto) -> Bool {
        return delegate?.recentView(self, photoView: photoView, shouldDeselectFor: photo) ?? true
    }
    
    func photoView(_ photoView: SAPhotoView, didSelectFor photo: SAPhoto) {
        delegate?.recentView(self, photoView: photoView, didSelectFor: photo)
    }
    func photoView(_ photoView: SAPhotoView, didDeselectFor photo: SAPhoto) {
        delegate?.recentView(self, photoView: photoView, didDeselectFor: photo)
    }
}
