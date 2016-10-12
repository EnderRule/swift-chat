//
//  SAPhotoPickerForAssetsCell.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal class SAPhotoPickerForAssetsCell: UICollectionViewCell {
    
    var album: SAPhotoAlbum?
    
    var photo: SAPhoto? {
        set { return photoView.photo = newValue }
        get { return photoView.photo }
    }
    var photoIsSelected: Bool {
        set { return photoView.isSelected = newValue }
        get { return photoView.isSelected }
    }
    
    var allowsSelection: Bool {
        set { return photoView.allowsSelection = newValue }
        get { return photoView.allowsSelection }
    }
    
    weak var delegate: SAPhotoSelectionable? {
        set { return photoView.delegate = newValue }
        get { return photoView.delegate }
    }
    
    func updateEdge() {
        photoView.updateEdge()
    }
    func updateSelection() {
        photoView.updateSelection()
    }
    
    private func _init() {
        
        photoView.frame = contentView.bounds
        photoView.allowsSelection = true
        photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(photoView)
    }
    
    lazy var photoView: SAPhotoView = SAPhotoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
