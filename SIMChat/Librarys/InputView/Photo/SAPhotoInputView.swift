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
// [ ] SAPhotoBrowser - 预加载(左右)
// [ ] SAPhotoBrowser - 加载进度
// [ ] SAPhotoBrowser - 视频
// [ ] SAPhotoBrowser - 音频
// [ ] SAPhotoBrowser - GIF
// [x] SAPhotoBrowserView - 横屏支持
// [ ] SAPhotoBrowserView - 转屏后的恢复图片中心位置
// [x] SAPhotoBrowserView - 图片缩放
// [x] SAPhotoBrowserView - 图片旋转
// [x] SAPhotoBrowserView - 双击放大
// [x] SAPhotoBrowserView - 双击放大(双击的地方要居中)
// [x] SAPhotoPicker - 相册列表
// [x] SAPhotoPicker - 图片列表
// [x] SAPhotoPicker - 图片预览
// [ ] SAPhotoPicker - 选择原图(文件大小)
// [x] SAPhotoPicker - 拦截返回事件
// [ ] SAPhotoPicker - 默认barItem
// [ ] SAPhotoPicker - 支持Moments模式
// [x] SAPhotoPickerForAlbums - 图片变更通知处理
// [x] SAPhotoPickerForAlbums - 空相册处理
// [x] SAPhotoPickerForAlbums - 默认显示album
// [x] SAPhotoPickerForAssets - 数量
// [x] SAPhotoPickerForAssets - 单选支持
// [x] SAPhotoPickerForAssets - 选中
// [x] SAPhotoPickerForAssets - 批量选中
// [x] SAPhotoPickerForAssets - 图片变更通知处理(多张新增、多张删除、多张改变、同时改变、删除Album)
// [x] SAPhotoPickerForAssets - 图片变更时的选中问题(检查图片是否被删除, 如果被删除将取消选中)
// [x] SAPhotoPickerForAssets - UIToolbar支持
// [x] SAPhotoPickerForAssets - 预览的item超出visableCells时的处理
// [ ] SAPhotoPickerForAssets - 跨界面转屏崩溃
// [x] SAPhotoPickerForPreviewer - 单选支持
// [x] SAPhotoPickerForPreviewer - 转场动画(弹出)
// [x] SAPhotoPickerForPreviewer - 横屏支持
// [ ] SAPhotoPickerForPreviewer - 手势(下拉)隐藏
// [x] SAPhotoPickerForPreviewer - 图片变更通知处理
// [x] SAPhotoPickerForPreviewer - 选中事件处理
// [x] SAPhotoPickerForPreviewer - 自定义toolbar
// [x] SAPhotoRecentlyView - 分离实现
// [x] SAPhotoRecentlyView - 错误显示 
// [x] SAPhotoRecentlyView - 横屏支持
// [x] SAPhotoRecentlyView - 图片变更(多张新增、多张删除、多张改变、同时改变)
// [x] SAPhotoRecentlyView - 图片变更时的选中问题(检查图片是否被删除, 如果被删除将取消选中)
// [ ] SAPhotoRecentlyView - 大小变更处理(宽/高)
// [x] SAPhotoToolbar - Item重用
// [ ] SAPhotoPreviewableAnimator - 图片变更动画
// [x] SAPhotoPreviewableAnimator - 图片旋转动画
// [x] SAPhotoPreviewableAnimator - contentMode变更动画
// [ ] SAPhotoPreviewableAnimator - 移动选择视图
// [x] SAPhotoInputView - 横屏支持
// [x] SAPhotoInputView - 预览选中的图片
// [ ] * - 发送图片(读取)


@objc
public protocol SAPhotoInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
}

open class SAPhotoInputView: UIView {
    
    open var allowsMultipleSelection: Bool = true {
        didSet {
            //_picker?.allowsMultipleSelection = allowsMultipleSelection
            _contentView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    open weak var delegate: SAPhotoInputViewDelegate?
        
        
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    func toolbarItems(for context: SAPhotoToolbarContext) -> [UIBarButtonItem]? {
        switch context {
        case .panel:    return [_pickBarItem, _editBarItem, _originalBarItem, _spaceBarItem, _sendBarItem]
        case .list:     return [_previewBarItem, _editBarItem, _originalBarItem, _spaceBarItem, _sendBarItem]
        case .preview:  return [_editBarItem, _originalBarItem, _spaceBarItem, _sendBarItem]
        default:        return nil
        }
    }
    
    fileprivate func _updateFileSize() {
        var title = "原图"
        
        if _isOriginalImage && !_selectedPhotos.isEmpty {
            title += "(\(_selectedPhotos.count)M)"
        }
        
        _originalBarItem.title = title
    }
    
    fileprivate func _updatePhotoCount() {
        
        if !_selectedPhotos.isEmpty {
            _sendBarItem.title = "发送(\(_selectedPhotos.count))"
        } else {
            _sendBarItem.title = "发送"
        }
        if _isOriginalImage {
            _updateFileSize()
        }
        
        _sendBarItem.isEnabled = !_selectedPhotos.isEmpty
        _editBarItem.isEnabled = _selectedPhotos.count == 1
        _previewBarItem.isEnabled = !_selectedPhotos.isEmpty
        _originalBarItem.isEnabled = !_selectedPhotos.isEmpty
    }
    
    
    private func _init() {
        _logger.trace()
        
//        let color = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
//        tintColor = color
        
        _pickBarItem = SAPhotoBarItem(title: "相册", type: .normal, target: self, action: #selector(onPicker(_:)))
        _editBarItem = SAPhotoBarItem(title: "编辑", type: .normal, target: self, action: #selector(onEditor(_:)))
        _sendBarItem = SAPhotoBarItem(title: "发送", type: .send, target: self, action: #selector(onSendForPicker(_:)))
        _previewBarItem = SAPhotoBarItem(title: "预览", type: .normal, target: self, action: #selector(onPreviewer(_:)))
        _originalBarItem = SAPhotoBarItem(title: "原图", type: .original, target: self, action: #selector(onChangeOriginal(_:)))
        
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        _tabbar.items = toolbarItems(for: .panel)
        
        _contentView.delegate = self
        _contentView.allowsMultipleSelection = allowsMultipleSelection
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
    
    fileprivate var _pickBarItem: SAPhotoBarItem!
    fileprivate var _previewBarItem: SAPhotoBarItem!
    fileprivate var _editBarItem: SAPhotoBarItem!
    fileprivate var _originalBarItem: SAPhotoBarItem!
    fileprivate var _sendBarItem: SAPhotoBarItem!
    fileprivate var _spaceBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    fileprivate weak var _picker: SAPhotoPicker?
    fileprivate weak var _previewer: SAPhotoPickerForPreviewer?
    
    fileprivate lazy var _tabbar: SAPhotoToolbar = SAPhotoToolbar()
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
        
        //_picker?.dismiss(animated: true, completion: nil)
        
        //_contentView.updateSelectionOfItems()
    }
    func onSendForInputView(_ sender: Any) {
        _logger.trace()
        
//        _selectedPhotos.removeAll()
//        _selectedPhotoSets.removeAll()
//        _contentView.updateSelectionOfItems()
    }
    func onChangeOriginal(_ sender: UIButton) {
        _isOriginalImage = !_isOriginalImage
        
        _originalBarItem.isSelected = _isOriginalImage
//        _original1BarItem.button.setImage(s, for: .normal)
//        _original1BarItem.button.setImage(n, for: .selected)
//        _original2BarItem.button.setImage(s, for: .normal)
//        _original2BarItem.button.setImage(n, for: .selected)
        
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
        
        picker.delegate = _contentView
        picker.allowsMultipleSelection = true
        
        viewController.present(picker, animated: true, completion: nil)
        
        _picker = picker
    }
    func onPreviewer(_ sender: Any) {
        _logger.trace(sender)
        
        _picker?.preview(with: SAPhotoPickerOptions(photos: _selectedPhotos))
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
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, didSelectItemFor photo: SAPhoto) {
        _logger.trace()
        
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
            _updatePhotoCount()
            _updateFileSize()
        }
    }
    
    // check whether item can deselect
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return true
    }
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, didDeselectItemFor photo: SAPhoto) {
        _logger.trace()
        
        if let idx = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: idx)
            _updatePhotoCount()
            _updateFileSize()
        }
    }
    
    open func recentlyView(_ recentlyView: SAPhotoRecentlyView, toolbarItemsFor context: SAPhotoToolbarContext) -> [UIBarButtonItem]? {
        return toolbarItems(for: context)
    }
}



