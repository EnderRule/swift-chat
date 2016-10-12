//
//  SAPhotoRecentlyViewCell.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
    

internal class SAPhotoRecentlyViewCell: UICollectionViewCell {
    
    var photo: SAPhoto? {
        set { return _photoView.photo = newValue }
        get { return _photoView.photo }
    }
    var photoIsSelected: Bool {
        return _photoView.isSelected
    }
    var allowsSelection: Bool {
        set { return _photoView.allowsSelection = newValue }
        get { return _photoView.allowsSelection }
    }
    
    weak var delegate: SAPhotoSelectionable? {
        set { return _photoView.delegate = newValue }
        get { return _photoView.delegate }
    }
    
    func updateEdge() {
        _photoView.updateEdge()
    }
    func updateSelection() {
        _photoView.updateSelection()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateEdge()
    }
    
    private func _init() {
        
        _photoView.frame = bounds
        _photoView.allowsSelection = true
        _photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_photoView)
        backgroundColor = .white
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
