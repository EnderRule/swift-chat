//
//  SAPhotoView.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal protocol SAPhotoViewDelegate: NSObjectProtocol {
    
    func photoView(_ photoView: SAPhotoView, indexForSelectWith photo: SAPhoto) -> Int
    
    func photoView(_ photoView: SAPhotoView, shouldSelectFor photo: SAPhoto) -> Bool
    func photoView(_ photoView: SAPhotoView, didSelectFor photo: SAPhoto)
    
    func photoView(_ photoView: SAPhotoView, shouldDeselectFor photo: SAPhoto) -> Bool
    func photoView(_ photoView: SAPhotoView, didDeselectFor photo: SAPhoto)
}

internal class SAPhotoView: UIView {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateEdge()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        _hightlightLayer.frame = _imageView.bounds
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard _selectedView.isUserInteractionEnabled else {
            return nil
        }
        let rect = UIEdgeInsetsInsetRect(_selectedView.frame, UIEdgeInsetsMake(-8, -8, -8, -8))
        if rect.contains(point) {
            return _selectedView
        }
        return nil
    }
    
    
    func updateEdge() {
        guard let window = window else {
            return
        }
        let x = convert(CGPoint(x: window.bounds.width, y: 0), from: window).x
        let edg = _contentInset

        var nframe = _selectedView.bounds
        
        // 悬停处理
        nframe.origin.x = max(min(x, bounds.width) - edg.right - nframe.width, edg.left)
        nframe.origin.y = edg.top
        
        if _selectedView.frame != nframe {
            _selectedView.frame = nframe
        }
    }
    func updateIndex() {
        _updateIndex()
    }
    
    var allowsSelection: Bool = true {
        willSet {
            guard allowsSelection != newValue else {
                return
            }
            _selectedView.isHidden = !newValue
            _selectedView.isUserInteractionEnabled = newValue
        }
    }
    
    var isSelected: Bool {
        set { return _setIsSelected(newValue, animated: false) }
        get { return _isSelected }
    }
    func setSelected(_ newValue: Bool, animated: Bool) {
        _setIsSelected(newValue, animated: animated)
        _updateIndex()
    }
    
    var photo: SAPhoto? {
        willSet {
            guard let newValue = newValue, photo !== newValue else {
                return
            }
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            
            SAPhotoLibrary.requestImage(for: newValue, targetSize: bounds.size, contentMode: .aspectFill, options: nil) { img, _ in
                //self._logger.trace(img)
                self._imageView.image = img
            }
        }
    }
    weak var delegate: SAPhotoViewDelegate?
    
    func onSelectItem(_ sender: Any) {
        guard let photo = photo else {
            return
        }
        if _isSelected {
            if delegate?.photoView(self, shouldDeselectFor: photo) ?? true {
                _setIsSelected(false, animated: true)
                delegate?.photoView(self, didDeselectFor: photo)
            }
        } else {
            if delegate?.photoView(self, shouldSelectFor: photo) ?? true {
                _setIsSelected(true, animated: true)
                delegate?.photoView(self, didSelectFor: photo)
                _updateIndex()
            }
        }
    }
    
    private func _updateIndex() {
        guard let photo = photo, isSelected else {
            return
        }
        let idx = delegate?.photoView(self, indexForSelectWith: photo) ?? 0
        // 添加数字
        _selectedView.setTitle("\(idx + 1)", for: .selected)
    }
    private func _setIsSelected(_ newValue: Bool, animated: Bool) {
        guard allowsSelection else {
            return
        }
        
        _isSelected = newValue
        _selectedView.isSelected = newValue
        _hightlightLayer.isHidden = !newValue
        
        // 选中时, 加点特效
        if animated {
            let a = CAKeyframeAnimation(keyPath: "transform.scale")
            
            a.values = [0.8, 1.2, 1]
            a.duration = 0.25
            a.calculationMode = kCAAnimationCubic
            
            _selectedView.layer.add(a, forKey: "v")
        }
    }
    
    private func _init() {
        
        _imageView.frame = bounds
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _hightlightLayer.isHidden = true
        _hightlightLayer.backgroundColor = UIColor(white: 0, alpha: 0.2).cgColor
        
        let edg = _contentInset
        _selectedView.frame = CGRect(x: bounds.width - edg.right - 23, y: edg.top, width: 23, height: 23)
        _selectedView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        _selectedView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        _selectedView.setTitleColor(.white, for: .normal)
        _selectedView.setBackgroundImage(UIImage(named: "aio_photo_checkbox_gray"), for: .normal)
        _selectedView.setBackgroundImage(UIImage(named: "aio_photo_checkbox_gray"), for: .highlighted)
        _selectedView.setBackgroundImage(UIImage(named: "aio_photo_checkbox_blue"), for: [.selected, .normal])
        _selectedView.setBackgroundImage(UIImage(named: "aio_photo_checkbox_blue"), for: [.selected, .highlighted])
        _selectedView.addTarget(self, action: #selector(onSelectItem(_:)), for: .touchUpInside)
        
        _imageView.layer.addSublayer(_hightlightLayer)
        
        addSubview(_imageView)
        addSubview(_selectedView)
    }
    
    private var _isSelected: Bool = false
    
    
    private lazy var _imageView: UIImageView = UIImageView()
    private lazy var _selectedView: UIButton = UIButton()
    private lazy var _hightlightLayer: CALayer = CALayer()
    
    private lazy var _contentInset: UIEdgeInsets = UIEdgeInsetsMake(4.5, 4.5, 4.5, 4.5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
