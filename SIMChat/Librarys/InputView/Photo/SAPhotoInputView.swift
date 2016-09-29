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

// [x] SAPhotoPicker - 错误显示 
// [x] SAPhotoPicker - 横屏支持
// [x] SAPhotoPicker - 图片变更(多张新增、多张删除、多张改变、同时改变、删除Album)
// [x] SAPhotoPicker - 图片变更时的选中问题

// [x] SAPhotoRecentlyView - 分离实现
// [x] SAPhotoRecentlyView - 错误显示 
// [x] SAPhotoRecentlyView - 横屏支持
// [x] SAPhotoRecentlyView - 图片变更(多张新增、多张删除、多张改变、同时改变)
// [x] SAPhotoRecentlyView - 图片变更时的选中问题

// [x] SAPhotoInputView - 横屏支持
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
        
        _original1BarItem.title = title
        _original2BarItem.title = title
    }
    
    fileprivate func _updatePhotoCount() {
        
        if !_selectedPhotos.isEmpty {
            _send1BarItem.title = "发送(\(_selectedPhotos.count))"
            _send2BarItem.title = "发送(\(_selectedPhotos.count))"
        } else {
            _send1BarItem.title = "发送"
            _send2BarItem.title = "发送"
        }
        if _isOriginalImage {
            _updateFileSize()
        }
        
        _send1BarItem.isEnabled = !_selectedPhotos.isEmpty
        _send2BarItem.isEnabled = !_selectedPhotos.isEmpty
        
        _edit1BarItem.isEnabled = _selectedPhotos.count == 1
        _edit2BarItem.isEnabled = _selectedPhotos.count == 1
        
        _previewBarItem.isEnabled = !_selectedPhotos.isEmpty
        
        _original1BarItem.isEnabled = !_selectedPhotos.isEmpty
        _original2BarItem.isEnabled = !_selectedPhotos.isEmpty
    }
    
    
    private func _init() {
        _logger.trace()
        
        let color = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        
        tintColor = color
        
        _pickBarItem = SAPhotoBarButtonItem(title: "相册", type: .normal, target: self, action: #selector(onPicker(_:)))
        _edit1BarItem = SAPhotoBarButtonItem(title: "编辑", type: .normal, target: self, action: #selector(onEditor(_:)))
        _edit2BarItem = SAPhotoBarButtonItem(title: "编辑", type: .normal, target: self, action: #selector(onEditor(_:)))
        _send1BarItem = SAPhotoBarButtonItem(title: "发送", type: .send, target: self, action: #selector(onSendForInputView(_:)))
        _send2BarItem = SAPhotoBarButtonItem(title: "发送", type: .send, target: self, action: #selector(onSendForPicker(_:)))
        _previewBarItem = SAPhotoBarButtonItem(title: "预览", type: .normal, target: self, action: #selector(onPreviewerForPicker(_:)))
        _original1BarItem = SAPhotoBarButtonItem(title: "原图", type: .original, target: self, action: #selector(onChangeOriginal(_:)))
        _original2BarItem = SAPhotoBarButtonItem(title: "原图", type: .original, target: self, action: #selector(onChangeOriginal(_:)))
        
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        _tabbar.items = [
            _pickBarItem,
            _edit1BarItem,
            _original1BarItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            _send1BarItem,
        ]
        
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
        
        
        _updatePhotoCount()
    }
    
    fileprivate var _isOriginalImage: Bool = false
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    fileprivate var _pickBarItem: SAPhotoBarButtonItem!
    fileprivate var _previewBarItem: SAPhotoBarButtonItem!
    
    fileprivate var _edit1BarItem: SAPhotoBarButtonItem!
    fileprivate var _edit2BarItem: SAPhotoBarButtonItem!
    
    fileprivate var _original1BarItem: SAPhotoBarButtonItem!
    fileprivate var _original2BarItem: SAPhotoBarButtonItem!
    
    fileprivate var _send1BarItem: SAPhotoBarButtonItem!
    fileprivate var _send2BarItem: SAPhotoBarButtonItem!
    
    fileprivate weak var _picker: SAPhotoPicker?
    fileprivate weak var _previewer: SAPhotoPreviewer?
    
    fileprivate lazy var _tabbar: UIToolbar = UIToolbar()
    fileprivate lazy var _contentView: SAPhotoRecentlyView = SAPhotoRecentlyView()
    
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
    
    func onSendForPicker(_ sender: Any) {
        _logger.trace()
        
        _picker?.dismiss(animated: true, completion: nil)
        
        _contentView.updateSelectionOfItmes()
    }
    func onSendForInputView(_ sender: Any) {
        _logger.trace()
        
//        _selectedPhotos.removeAll()
//        _selectedPhotoSets.removeAll()
//        _contentView.updateSelectionOfItmes()
    }
    func onChangeOriginal(_ sender: UIButton) {
        _isOriginalImage = !_isOriginalImage
        
        let n = sender.image(for: .normal)
        let s = sender.image(for: .selected)
        
        _original1BarItem.button.setImage(s, for: .normal)
        _original1BarItem.button.setImage(n, for: .selected)
        _original2BarItem.button.setImage(s, for: .normal)
        _original2BarItem.button.setImage(n, for: .selected)
        
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
        picker.view.tintColor = tintColor
        picker.toolbarItems = [
            _previewBarItem,
            _edit2BarItem,
            _original2BarItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            _send2BarItem,
        ]
        _picker = picker
        
        viewController.present(picker, animated: true, completion: nil)
    }
    func onPreviewerForInputView(_ sender: Any) {
        guard let viewController = UIApplication.shared.delegate?.window??.rootViewController else {
            return
        }
        let previewer = SAPhotoPreviewer()
        let nav = UINavigationController(rootViewController: previewer)
        
        previewer.dataSource = _contentView
        previewer.delegate = _contentView 
        
        viewController.present(nav, animated: true, completion: nil)
        _previewer = previewer
    }
    func onPreviewerForPicker(_ sender: Any) {
        guard let viewController = _picker else {
            return
        }
        let previewer = SAPhotoPreviewer()
        let nav = UINavigationController(rootViewController: previewer)
        viewController.present(nav, animated: true, completion: nil)
        _previewer = previewer
//        let previewer = SAPhotoPreviewer()
//        
//        _previewer = previewer
    }
    
    func selectItem(for photo: SAPhoto) {
        _logger.trace(photo)
        
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
            _updatePhotoCount()
            _updateFileSize()
        }
    }
    func deselectItem(for photo: SAPhoto) {
        _logger.trace(photo)
        
        if let idx = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: idx)
            _updatePhotoCount()
            _updateFileSize()
        }
    }
    
}

// MARK: - SAPhotoPreviewerDataSource & SAPhotoPreviewerDelegate

//extension SAPhotoInputView: SAPhotoPreviewerDataSource, SAPhotoPreviewerDelegate {
    
//    open func numberOfPhotos(in previewer: SAPhotoPreviewer) -> Int {
//        return _selectedPhotos.count
//    }
//
//    open func photoPreviewer(_ photoPreviewer: SAPhotoPreviewer, photoForItemAt index: Int) -> SAPhoto {
//        return _
//    }
//}

// MARK: - SAPhotoPickerDelegate

extension SAPhotoInputView: SAPhotoPickerDelegate {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    open func picker(_ picker: SAPhotoPicker, indexOfSelectedItemsFor photo: SAPhoto) -> Int {
        return _selectedPhotos.index(of: photo) ?? NSNotFound
    }
   
    // check whether item can select
    open func picker(_ picker: SAPhotoPicker, shouldSelectItemFor photo: SAPhoto) -> Bool {
        // 可以在这里进行数量限制/图片类型限制
        //
        // if _selectedPhotoSets.count >= 9 {
        //     return false // 只能选择9张图片
        // }
        // if photo.mediaType != .image {
        //     return false // 只能选择图片
        // }
        return true
    }
    open func picker(_ picker: SAPhotoPicker, didSelectItemFor photo: SAPhoto) {
        selectItem(for: photo)
    }
    
    // check whether item can deselect
    open func picker(_ picker: SAPhotoPicker, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return true
    }
    open func picker(_ picker: SAPhotoPicker, didDeselectItemFor photo: SAPhoto) {
        deselectItem(for: photo)
    }
    
    // tap item
    open func picker(_ picker: SAPhotoPicker, tapItemFor photo: SAPhoto, with sender: Any) {
        _logger.trace()
    }
    
    // MARK: Display
    
    open func picker(didDismiss picker: SAPhotoPicker) {
        _logger.trace()
        // 隐藏的时候同步更新选择的items
        _contentView.updateSelectionOfItmes()
    }
}

// MARK: - SAPhotoRecentlyViewDelegate

extension SAPhotoInputView: SAPhotoRecentlyViewDelegate {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, indexOfSelectedItemsFor photo: SAPhoto) -> Int {
        return _selectedPhotos.index(of: photo) ?? NSNotFound
    }
   
    // check whether item can select
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldSelectItemFor photo: SAPhoto) -> Bool {
        return true
    }
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, didSelectItemFor photo: SAPhoto) {
        selectItem(for: photo)
    }
    
    // check whether item can deselect
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return true
    }
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, didDeselectItemFor photo: SAPhoto) {
        deselectItem(for: photo)
    }
    
    // tap item
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, tapItemFor photo: SAPhoto, with sender: Any) {
        _logger.trace()
    }
}

