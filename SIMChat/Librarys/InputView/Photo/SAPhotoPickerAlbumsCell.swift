//
//  SAPhotoPickerAlbumsCell.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoPickerAlbumsCell: UITableViewCell {

    var album: SAPhotoAlbum? {
        didSet {
            guard let newValue = album else {
                return
            }
            
            _titleLabel.text = newValue.title
            _descriptionLabel.text = "\(newValue.photos.count)"
            
            _stackView.layoutIfNeeded()
            
            let count = newValue.photos.count
            let photos = (0 ..< 3).flatMap { index -> SAPhoto? in
                guard index < count else {
                    return nil
                }
                return newValue.photos[count - index - 1]
            }
            
            _updatePhotos(photos)
        }
    }
    
    private func _updatePhotos(_ photos: [SAPhoto]) {
        //_logger.trace(photos.count)
        
        _stackView.layers.forEach {
            if photos.isEmpty {
                $0.isHidden = false
                $0.backgroundColor = UIColor(white: 0.8, alpha: 1).cgColor
                $0.contents = nil
            } else {
                $0.isHidden = true
                $0.backgroundColor = UIColor.white.cgColor
                $0.contents = nil
            }
        }
        
        guard !photos.isEmpty else {
            return 
        }
        
        let taskId = UUID().uuidString
        _taskId = taskId
        
        photos.enumerated().forEach { 
            
            let layer = _stackView.layers[$0.offset]
            
            layer.isHidden = false
            
            let scale = UIScreen.main.scale
            let size = CGSize(width: _stackView.bounds.width * scale, 
                              height: _stackView.bounds.height * scale)
            
            _ = SAPhotoLibrary.shared.requestImage(for: $0.element, targetSize: size, contentMode: .aspectFill) { img, _ in
                guard self._taskId == taskId else {
                    return
                }
                layer.contents = img?.cgImage
            }
        }
    }
    
    private func _init() {
        
        _stackView.translatesAutoresizingMaskIntoConstraints = false
        
        _titleLabel.text = "Title"
        _titleLabel.font = UIFont.systemFont(ofSize: 18)
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
       
        _descriptionLabel.text = "Description"
        _descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(_stackView)
        contentView.addSubview(_titleLabel)
        contentView.addSubview(_descriptionLabel)
        
        addConstraint(_SALayoutConstraintMake(_stackView, .left, .equal, contentView, .left, 8))
        addConstraint(_SALayoutConstraintMake(_stackView, .centerY, .equal, contentView, .centerY))
        
        addConstraint(_SALayoutConstraintMake(_stackView, .width, .equal, _stackView, .height))
        addConstraint(_SALayoutConstraintMake(_stackView, .height, .equal, nil, .notAnAttribute, 70))
        
        addConstraint(_SALayoutConstraintMake(_titleLabel, .left, .equal, _stackView, .right, 8))
        addConstraint(_SALayoutConstraintMake(_titleLabel, .right, .equal, contentView, .right))
        addConstraint(_SALayoutConstraintMake(_titleLabel, .bottom, .equal, contentView, .centerY))
        
        addConstraint(_SALayoutConstraintMake(_descriptionLabel, .top, .equal, contentView, .centerY))
        addConstraint(_SALayoutConstraintMake(_descriptionLabel, .left, .equal, _stackView, .right, 8))
        addConstraint(_SALayoutConstraintMake(_descriptionLabel, .right, .equal, contentView, .right))
    }
    
    private var _taskId: String?
    
    private lazy var _stackView: SAPhotoStackView = SAPhotoStackView()
    private lazy var _titleLabel: UILabel = UILabel()
    private lazy var _descriptionLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
