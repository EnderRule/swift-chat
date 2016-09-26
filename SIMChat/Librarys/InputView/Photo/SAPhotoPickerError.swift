//
//  SAPhotoPickerError.swift
//  SIMChat
//
//  Created by sagesse on 9/26/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerError: UIViewController {
    
    var font: UIFont? {
        set { return _titleLabel.font = newValue }
        get { return _titleLabel.font }
    }
    
    var text: String? {
        set { return _titleLabel.text = newValue }
        get { return _titleLabel.text }
    }
    var textColor: UIColor? {
        set { return _titleLabel.textColor = newValue }
        get { return _titleLabel.textColor }
    }
    var textAlignment: NSTextAlignment {
        set { return _titleLabel.textAlignment = newValue }
        get { return _titleLabel.textAlignment }
    }
    
    var image: UIImage? {
        set { return _imageView.image = newValue }
        get { return _imageView.image }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIView()
        
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false

        _imageView.translatesAutoresizingMaskIntoConstraints = false
        
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        _titleLabel.font = UIFont.systemFont(ofSize: 15)
        _titleLabel.textColor = .lightGray
        _titleLabel.textAlignment = .center
        _titleLabel.numberOfLines = 0
        
        container.addSubview(_imageView)
        container.addSubview(_titleLabel)
        container.addConstraints([
            _SALayoutConstraintMake(_imageView, .top, .equal, container, .top),
            _SALayoutConstraintMake(_imageView, .centerX, .equal, container, .centerX),
            
            _SALayoutConstraintMake(_titleLabel, .top, .equal, _imageView, .bottom, 16),
            _SALayoutConstraintMake(_titleLabel, .left, .equal, container, .left),
            _SALayoutConstraintMake(_titleLabel, .right, .equal, container, .right),
            _SALayoutConstraintMake(_titleLabel, .bottom, .equal, container, .bottom),
        ])
        
        view.addSubview(container)
        view.addConstraints([
            _SALayoutConstraintMake(container, .centerX, .equal, view, .centerX),
            _SALayoutConstraintMake(container, .centerY, .equal, view, .centerY),
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = true
    }

    private lazy var _imageView: UIImageView = UIImageView()
    private lazy var _titleLabel: UILabel = UILabel()
    
    
    init(image: UIImage?, title: String?) {
        super.init(nibName: nil, bundle: nil)
        
        _imageView.image = image
        _titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
