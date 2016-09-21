//
//  SAPhotoInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


// # TODO
// [ ] SAPhotoView - 异步加载
// [ ] SAPhotoView - 渐进式解码
// [x] SAPhotoView - 选择顺序
// [x] SAPhotoView - 选中支持
// [x] SAPhotoView - 选中高亮支持
// [x] SAPhotoView - SelectView悬停
// [ ] SAPhotoView - iClound图片下载进度显示
// [ ] SAPhotoBrowser - 实现
// [ ] SAPhotoBrowser - 错误显示(无权限显示)
// [ ] SAPhotoBrowser - 图片更新通知
// [x] SAPhotoRecentlyView - 分离实现
// [x] SAPhotoInputView - 横屏支持
// [ ] SAPhotoInputView - 错误显示
// [ ] SAPhotoInputView - 初次加载页面
// [ ] * - 发送图片(读取)


@objc
public protocol SAPhotoInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
}

open class SAPhotoInputView: UIView {
    
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    open weak var delegate: SAPhotoInputViewDelegate?
    
    
    fileprivate func _updateFileSize() {
        var title = "原图"
        
        if _isOriginalImage && !_selectedPhotos.isEmpty {
            title += "(\(_selectedPhotos.count)M)"
        }
        
        _originalBarItem.titleLabel?.text = title // 先更新titleLabel是因为防止系统执行更新title的动画
        _originalBarItem.setTitle(title, for: .normal)
        _originalBarItem.sizeToFit()
    }
    
    fileprivate func _updatePhotoCount() {
        
        if !_selectedPhotos.isEmpty {
            _sendBarItem.isEnabled = true
            _sendBarItem.setTitle("发送(\(_selectedPhotos.count))", for: .normal)
            _sendBarItem.sizeToFit()
        } else {
            _sendBarItem.isEnabled = false
            _sendBarItem.setTitle("发送", for: .normal)
            _sendBarItem.sizeToFit()
        }
//        if _isOriginalImage {
//            _updateFileSize()
//        }
        
        _editorBarItem.isEnabled = _selectedPhotos.count == 1
        
        var nframe = _sendBarItem.frame
        nframe.size.width = max(nframe.width, 70)
        _sendBarItem.frame = nframe
    }
    
    private func _init() {
        _logger.trace()
        
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        
        autoreleasepool {
            
            let font = UIFont.systemFont(ofSize: 17)
            let color = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
            let dcolor = UIColor.lightGray
            
            _pickerbarItem.titleLabel?.font = font
            _pickerbarItem.setTitle("相册", for: .normal)
            _pickerbarItem.setTitleColor(color, for: .normal)
            _pickerbarItem.setTitleColor(dcolor, for: .disabled)
            _pickerbarItem.addTarget(self, action: #selector(onPicker(_:)), for: .touchUpInside)
            _pickerbarItem.sizeToFit()
            
            _editorBarItem.titleLabel?.font = font
            _editorBarItem.setTitle("编辑", for: .normal)
            _editorBarItem.setTitleColor(color, for: .normal)
            _editorBarItem.setTitleColor(dcolor, for: .disabled)
            _editorBarItem.addTarget(self, action: #selector(onEditor(_:)), for: .touchUpInside)
            _editorBarItem.sizeToFit()
            
            let smn = UIImage(named: "photo_small_checkbox_normal")
            let smh = UIImage(named: "photo_small_checkbox_selected")
            let smd = UIImage(named: "photo_small_checkbox_disabled")
            
            _originalBarItem.titleLabel?.font = font
            _originalBarItem.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4)
            _originalBarItem.setTitle("原图", for: .normal)
            _originalBarItem.setTitleColor(color, for: .normal)
            _originalBarItem.setTitleColor(dcolor, for: .disabled)
            _originalBarItem.setImage(smn?.withRenderingMode(.alwaysOriginal), for: .normal)
            _originalBarItem.setImage(smh?.withRenderingMode(.alwaysOriginal), for: .selected)
            _originalBarItem.setImage(smd?.withRenderingMode(.alwaysOriginal), for: .disabled)
            _originalBarItem.addTarget(self, action: #selector(onChangeOriginal(_:)), for: .touchUpInside)
            _originalBarItem.sizeToFit()
            
            _sendBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            _sendBarItem.setTitle("发送", for: .normal)
            _sendBarItem.setTitleColor(.white, for: .normal)
            _sendBarItem.setTitleColor(.lightGray, for: .disabled)
            _sendBarItem.contentEdgeInsets = UIEdgeInsetsMake(6, 8, 6, 8)
            _sendBarItem.setBackgroundImage(UIImage(named: "photo_button_nor"), for: .normal)
            _sendBarItem.setBackgroundImage(UIImage(named: "photo_button_press"), for: .highlighted)
            _sendBarItem.setBackgroundImage(UIImage(named: "photo_button_disabled"), for: .disabled)
            _sendBarItem.addTarget(self, action: #selector(onSend(_:)), for: .touchUpInside)
            _sendBarItem.sizeToFit()
            _sendBarItem.frame = CGRect(x: 0, y: 0, width: 70, height: _sendBarItem.frame.height)
            
            _tabbar.items = [
                UIBarButtonItem(customView: _pickerbarItem),
                UIBarButtonItem(customView: _editorBarItem),
                UIBarButtonItem(customView: _originalBarItem),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(customView: _sendBarItem),
            ]
            
            _sendBarItem.isEnabled = false
            _editorBarItem.isEnabled = false
        }
        
        _contentView.delegate = self
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_contentView)
        addSubview(_tabbar)
        
        addConstraint(_SALayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_contentView, .right, .equal, self, .right))
        
        addConstraint(_SALayoutConstraintMake(_tabbar, .top, .equal, _contentView, .bottom))
        addConstraint(_SALayoutConstraintMake(_tabbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_tabbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_tabbar, .height, .equal, nil, .notAnAttribute, 44))
    }
    
    fileprivate var _isOriginalImage: Bool = false
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    fileprivate lazy var _sendBarItem = UIButton()
    fileprivate lazy var _pickerbarItem = UIButton(type: .system)
    fileprivate lazy var _editorBarItem = UIButton(type: .system)
    fileprivate lazy var _originalBarItem = UIButton(type: .system)
    
    fileprivate lazy var _tabbar: UIToolbar = UIToolbar()
    fileprivate lazy var _contentView: SAPhotoRecentlyView = SAPhotoRecentlyView()
    
    
    fileprivate var _picker: SAPhotoPicker?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - Touch Events

extension SAPhotoInputView {
    
    func onSend(_ sender: Any) {
        _logger.trace()
    }
    func onChangeOriginal(_ sender: UIButton) {
        _isOriginalImage = !_isOriginalImage
        
        let n = sender.image(for: .normal)
        let s = sender.image(for: .selected)
        sender.setImage(s, for: .normal)
        sender.setImage(n, for: .selected)
        
        // 更新文件大小
        _updateFileSize()
    }
    
    func onEditor(_ sender: Any) {
        _logger.trace(sender)
    }
    func onPicker(_ sender: Any) {
        guard let viewController = UIApplication.shared.delegate?.window??.rootViewController else {
            return
        }
        let picker = SAPhotoPicker()
        picker.delegate = self
        picker.show(in: viewController)
        _picker = picker
    }
    func onPreviewer(_ sender: Any) {
        _logger.trace(sender)
    }
    
    func onSelectItem(_ photo: SAPhoto) {
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
            _updatePhotoCount()
        }
    }
    func onDeselectItem(_ photo: SAPhoto) {
        if let idx = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: idx)
            _updatePhotoCount()
        }
    }
}

// MARK: - SAPhotoPickerDelegate

extension SAPhotoInputView: SAPhotoPickerDelegate {
    
    public func photoPicker(_ photoPicker: SAPhotoPicker, indexOfSelectedItem photo: SAPhoto) -> Int {
        return _selectedPhotos.index(of: photo) ?? 0
    }
    public func photoPicker(_ photoPicker: SAPhotoPicker, isSelectedOfItem photo: SAPhoto) -> Bool {
        return _selectedPhotoSets.contains(photo)
    }
    
    public func photoPicker(_ photoPicker: SAPhotoPicker, previewItem photo: SAPhoto, in view: UIView) {
        onPreviewer(photo)
    }
    
    public func photoPicker(_ photoPicker: SAPhotoPicker, shouldSelectItem photo: SAPhoto) -> Bool {
        return true
    }
    public func photoPicker(_ photoPicker: SAPhotoPicker, didSelectItem photo: SAPhoto) {
        onSelectItem(photo)
    }
    
    public func photoPicker(_ photoPicker: SAPhotoPicker, shouldDeselectItem photo: SAPhoto) -> Bool {
        return true
    }
    public func photoPicker(_ photoPicker: SAPhotoPicker, didDeselectItem photo: SAPhoto) {
        onDeselectItem(photo)
    }
}

// MARK: - SAPhotoRecentlyViewDelegate

extension SAPhotoInputView: SAPhotoRecentlyViewDelegate {
    
    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, indexOfSelectedItem photo: SAPhoto) -> Int {
        return _selectedPhotos.index(of: photo) ?? 0
    }
    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, isSelectedOfItem photo: SAPhoto) -> Bool {
        return _selectedPhotoSets.contains(photo)
    }
    
    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, previewItem photo: SAPhoto, in view: UIView) {
        onPreviewer(photo)
    }
    
    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldSelectItem photo: SAPhoto) -> Bool {
        return true
    }
    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, didSelectItem photo: SAPhoto) {
        onSelectItem(photo)
    }
    
    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldDeselectItem photo: SAPhoto) -> Bool {
        return true
    }
    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, didDeselectItem photo: SAPhoto) {
        onDeselectItem(photo)
    }
}
