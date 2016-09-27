//
//  SAPhotoView.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoView: UIView {
    
    var photo: SAPhoto? {
        didSet {
            if oldValue !== photo {
                _updatePhoto(photo, animated: true)
            }
            _updateSelection(_isSelected, animated: false)
        }
    }
    
    var isSelected: Bool {
        set { return _updateSelection(newValue, animated: false) }
        get { return _isSelected }
    }
    var allowsSelection: Bool = true {
        willSet {
            guard newValue != allowsSelection else {
                return
            }
            _updateAllowsSelection(newValue, animated: false)
        }
    }
    
    weak var delegate: SAPhotoSelectionable?
   
    
    func setSelected(_ newValue: Bool, animated: Bool) {
        _updateSelection(newValue, animated: animated)
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
    func updateSelection() {
        _updateSelection(_isSelected, animated: false)
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else {
            return nil
        }
        guard _selectedView.isUserInteractionEnabled else {
            return self
        }
        let rect = UIEdgeInsetsInsetRect(_selectedView.frame, UIEdgeInsetsMake(-8, -8, -8, -8))
        if rect.contains(point) {
            return _selectedView
        }
        return self
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        _hightlightLayer.frame = _imageView.bounds
    }
    
    
    @objc private func tapHandler(_ sender: Any) {
        guard let photo = photo else {
            return
        }
        delegate?.selection(self, tapItemFor: photo)
    }
    @objc private func selectHandler(_ sender: Any) {
        guard let photo = photo else {
            return
        }
        if _isSelected {
            guard delegate?.selection(self, shouldDeselectItemFor: photo) ?? true else {
                return
            }
            delegate?.selection(self, didDeselectItemFor: photo)
        } else {
            guard delegate?.selection(self, shouldSelectItemFor: photo) ?? true else {
                return
            }
            delegate?.selection(self, didSelectItemFor: photo)
        }
        setSelected(!_isSelected, animated: true)
    }
    
    private func _updatePhoto(_ newValue: SAPhoto?, animated: Bool) {
        guard let newValue = newValue else {
            return
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        
        let scale = UIScreen.main.scale
        let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)
        
        SAPhotoLibrary.shared.requestImage(for: newValue, targetSize: size, contentMode: .aspectFill, options: nil) { img, _ in
            guard self.photo == newValue else {
                return
            }
            //self._logger.trace(img)
            self._imageView.image = img
        }
    }
    
    private func _updateSelection(_ newValue: Bool, animated: Bool) {
        guard let photo = photo, allowsSelection else {
            return
        }
        //_logger.trace()
        
        if let index = delegate?.selection(self, indexOfSelectedItemsFor: photo), index != NSNotFound {
            
            _isSelected = true
            _selectedView.isSelected = _isSelected
            _hightlightLayer.isHidden = !_isSelected
            
            _selectedView.setTitle("\(index + 1)", for: .selected)
            
        } else {
            
            _isSelected = false
            _selectedView.isSelected = _isSelected
            _hightlightLayer.isHidden = !_isSelected
        }
        
        // 选中时, 加点特效
        if animated {
            let a = CAKeyframeAnimation(keyPath: "transform.scale")
            
            a.values = [0.8, 1.2, 1]
            a.duration = 0.25
            a.calculationMode = kCAAnimationCubic
            
            _selectedView.layer.add(a, forKey: "v")
        }
    }
    private func _updateAllowsSelection(_ newValue: Bool, animated: Bool) {
        _logger.trace()
        
        _selectedView.isHidden = !newValue
        _selectedView.isUserInteractionEnabled = newValue
        
        if !_hightlightLayer.isHidden && !newValue {
            _hightlightLayer.isHidden = true
        }
    }
    
    private func _init() {
        //_logger.trace()
        
        _imageView.frame = bounds
        _imageView.contentMode = .scaleAspectFill
        _imageView.clipsToBounds = true
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _hightlightLayer.isHidden = true
        _hightlightLayer.backgroundColor = UIColor(white: 0, alpha: 0.2).cgColor
        
        let edg = _contentInset
        _selectedView.frame = CGRect(x: bounds.width - edg.right - 23, y: edg.top, width: 23, height: 23)
        _selectedView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        _selectedView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        _selectedView.setTitleColor(.white, for: .normal)
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_normal"), for: .normal)
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_normal"), for: .highlighted)
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_selected"), for: [.selected, .normal])
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_selected"), for: [.selected, .highlighted])
        _selectedView.addTarget(self, action: #selector(selectHandler(_:)), for: .touchUpInside)
        
        _imageView.layer.addSublayer(_hightlightLayer)
        
        addSubview(_imageView)
        addSubview(_selectedView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        addGestureRecognizer(tap)
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
