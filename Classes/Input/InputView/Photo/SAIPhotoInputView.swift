//
//  SAPhotoInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


// # TODO
// [x] SAPhotoView - 异步加载
// [ ] SAPhotoView - 渐进式解码
// [x] SAPhotoView - 选择顺序
// [x] SAPhotoView - 选中支持
// [x] SAPhotoView - 选中高亮支持
// [x] SAPhotoView - SelectView悬停
// [ ] SAPhotoView - iClound图片下载进度显示
// [ ] SAPhotoView - iClound图标
// [x] SAPhotoView - 媒体类型图标
// [x] SAPhotoAlbumStackView - 空相册图标
// [x] SAPhotoAlbumStackView - 相册类型图标
// [ ] SAPhotoBrowser - 实现
// [ ] SAPhotoBrowser - 错误显示(无权限显示)
// [ ] SAPhotoBrowser - 图片更新通知
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
// [ ] SAPhotoBrowserView - iClound图片下载进度显示
// [x] SAPhotoPicker - 相册列表
// [x] SAPhotoPicker - 图片列表
// [x] SAPhotoPicker - 图片预览
// [x] SAPhotoPicker - 选择原图(文件大小)
// [x] SAPhotoPicker - 拦截返回事件
// [x] SAPhotoPicker - 默认barItem
// [ ] SAPhotoPicker - 支持Moments模式
// [x] SAPhotoPickerForAlbums - 图片变更通知处理
// [x] SAPhotoPickerForAlbums - 空相册处理
// [x] SAPhotoPickerForAlbums - 默认显示album
// [ ] SAPhotoPickerForAssets - 快速滚动时有性能问题
// [x] SAPhotoPickerForAssets - 数量
// [x] SAPhotoPickerForAssets - 单选支持
// [x] SAPhotoPickerForAssets - 选中
// [x] SAPhotoPickerForAssets - 批量选中
// [x] SAPhotoPickerForAssets - 图片变更通知处理(多张新增、多张删除、多张改变、同时改变、删除Album)
// [x] SAPhotoPickerForAssets - 图片变更时的选中问题(检查图片是否被删除, 如果被删除将取消选中)
// [x] SAPhotoPickerForAssets - UIToolbar支持
// [x] SAPhotoPickerForAssets - 预览的item超出visableCells时的处理
// [ ] SAPhotoPickerForAssets - 跨界面转屏崩溃
// [x] SAPhotoPickerForAssets - 默认显示在底部
// [x] SAPhotoPickerForAssets - 底部显示图片数量
// [ ] SAPhotoPickerForAssets - 当有大量的图片变更时, 可能会导致应用卡死
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
// [x] SAPhotoPreviewableAnimator - 图片变更动画(渐变)
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

public class SAPhotoInputView: UIView {
    
    public var allowsMultipleSelection: Bool = true {
        didSet {
            //_picker?.allowsMultipleSelection = allowsMultipleSelection
            //_contentView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    public weak var delegate: SAPhotoInputViewDelegate?
        
        
    public override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
//    func toolbarItems(for context: SAPhotoToolbarContext) -> [UIBarButtonItem]? {
//        switch context {
//        case .panel:    return [_pickBarItem, _editBarItem, _originalBarItem, _spaceBarItem, _sendBarItem]
//        default:        return nil
//        }
//    }
//    
//    private func _init() {
//        _logger.trace()
//        
////        let color = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
////        tintColor = color
//        
//        _pickBarItem = SAPhotoBarItem(title: "相册", type: .normal, target: self, action: #selector(pickerHandler(_:)))
//        _editBarItem = SAPhotoBarItem(title: "编辑", type: .normal, target: self, action: #selector(onEditor(_:)))
//        _sendBarItem = SAPhotoBarItem(title: "发送", type: .send, target: self, action: #selector(onSendForPicker(_:)))
//        _originalBarItem = SAPhotoBarItem(title: "原图", type: .original, target: self, action: #selector(onChangeOriginal(_:)))
//        
//        _tabbar.translatesAutoresizingMaskIntoConstraints = false
//        _tabbar.items = toolbarItems(for: .panel)
//        
//        _contentView.delegate = self
//        _contentView.allowsMultipleSelection = allowsMultipleSelection
//        _contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        addSubview(_contentView)
//        addSubview(_tabbar)
//        
//        addConstraint(_SALayoutConstraintMake(_contentView, .top, .equal, self, .top))
//        addConstraint(_SALayoutConstraintMake(_contentView, .left, .equal, self, .left))
//        addConstraint(_SALayoutConstraintMake(_contentView, .right, .equal, self, .right))
//        
//        addConstraint(_SALayoutConstraintMake(_tabbar, .top, .equal, _contentView, .bottom))
//        addConstraint(_SALayoutConstraintMake(_tabbar, .left, .equal, self, .left))
//        addConstraint(_SALayoutConstraintMake(_tabbar, .right, .equal, self, .right))
//        addConstraint(_SALayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom))
//        
//        addConstraint(_SALayoutConstraintMake(_tabbar, .height, .equal, nil, .notAnAttribute, 44))
//        
//        
//        _updatePhotoCount(0)
//    }
//    
//    fileprivate var _isOriginalImage: Bool = false
//    
//    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
//    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
//    
//    fileprivate var _pickBarItem: SAPhotoBarItem!
//    fileprivate var _editBarItem: SAPhotoBarItem!
//    fileprivate var _originalBarItem: SAPhotoBarItem!
//    fileprivate var _sendBarItem: SAPhotoBarItem!
//    fileprivate var _spaceBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//    
//    fileprivate lazy var _tabbar: SAPhotoToolbar = SAPhotoToolbar()
//    fileprivate lazy var _contentView: SAPhotoRecentlyView = SAPhotoRecentlyView()
//    
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        _init()
//    }
//    public required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        _init()
//    }
//}
//
//// MARK: - Touch Events
//
//extension SAPhotoInputView {
//    
//    func onSendForPicker(_ sender: Any) {
//        _logger.trace()
//        
//        //_picker?.dismiss(animated: true, completion: nil)
//        
//        //_contentView.updateSelectionOfItems()
//    }
//    func onChangeOriginal(_ sender: UIButton) {
//        _logger.trace()
//        
//        _contentView.alwaysSelectOriginal = !_contentView.alwaysSelectOriginal
//        _originalBarItem.isSelected = _contentView.alwaysSelectOriginal
//    }
//    
//    func pickerHandler(_ sender: Any) {
//        _logger.trace()
//        
//        _showPicker()
//    }
//    
//    func onEditor(_ sender: Any) {
//        _logger.trace(sender)
//    }
//    
//    func confrim(photos: Array<SAPhoto>) {
//        _logger.trace()
//        
////        // 清除所有选中
////        _contentView.selectedPhotos = []
////        _updatePhotoCount()
//    }
//    func cancel(photo: Array<SAPhoto>) {
//        _logger.trace()
//        
////        // 清除所有选中
////        _contentView.selectedPhotos = []
////        _updatePhotoCount()
//    }
//    
//}
//
//fileprivate extension SAPhotoInputView {
//    
//    func _updatePhotoCount(_ count: Int) {
//        
//        if count != 0 {
//            _sendBarItem.title = "发送(\(count))"
//        } else {
//            _sendBarItem.title = "发送"
//        }
//        
//        _editBarItem.isEnabled = count == 1
//        _sendBarItem.isEnabled = count != 0
//        _originalBarItem.isEnabled = count != 0
//    }
//    func _updateBytesLenght(_ lenght: Int) {
//        _logger.trace(lenght)
//        
//        if !_contentView.alwaysSelectOriginal || lenght <= 0 {
//            _originalBarItem.title = "原图"
//        } else {
//            _originalBarItem.title = "原图(\(SAPhotoFormatBytesLenght(lenght)))"
//        }
//    }
//    
//    /// 显示图片选择器
//    func _showPicker() {
//        guard let window = UIApplication.shared.delegate?.window else {
//            return // no window, is unknow error
//        }
//        let picker = SAPhotoPicker()
//        
//        picker.delegate = self
//        picker.selectedPhotos = _contentView.selectedPhotos
//        
//        picker.allowsEditing = _contentView.allowsEditing
//        picker.allowsMultipleSelection = _contentView.allowsMultipleSelection
//        picker.alwaysSelectOriginal = _contentView.alwaysSelectOriginal
//        
//        window?.rootViewController?.present(picker, animated: true, completion: nil)
//    }
//    /// 显示图片选择器(预览模式)
//    func _showPickerForPreview(_ photo: SAPhoto) {
//        guard let window = UIApplication.shared.delegate?.window else {
//            return // no window, is unknow error
//        }
//        let options = SAPhotoPickerOptions(album: photo.album, default: photo, ascending: false)
//        let picker = SAPhotoPicker(preview: options)
//            
//        picker.delegate = self
//        picker.selectedPhotos = _contentView.selectedPhotos
//        
//        picker.allowsEditing = _contentView.allowsEditing
//        picker.allowsMultipleSelection = _contentView.allowsMultipleSelection
//        picker.alwaysSelectOriginal = _contentView.alwaysSelectOriginal
//        
//        window?.rootViewController?.present(picker, animated: true, completion: nil)
//    }
//}
//
//// MARK: - SAPhotoRecentlyViewDelegate
//
//extension SAPhotoInputView: SAPhotoRecentlyViewDelegate {
//    
//    // check whether item can select
//    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldSelectItemFor photo: SAPhoto) -> Bool {
//        // 可以在这里进行数量限制/图片类型限制
//        //
//        // if _selectedPhotoSets.count >= 9 {
//        //     return false // 只能选择9张图片
//        // }
//        // if photo.mediaType != .image {
//        //     return false // 只能选择图片
//        // }
//        return true
//    }
//    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, didSelectItemFor photo: SAPhoto) {
//        _logger.trace()
//        
//        _updatePhotoCount(recentlyView.selectedPhotos.count)
//    }
//    
//    // check whether item can deselect
//    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldDeselectItemFor photo: SAPhoto) -> Bool {
//        return true
//    }
//    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, didDeselectItemFor photo: SAPhoto) {
//        _logger.trace()
//        
//        _updatePhotoCount(recentlyView.selectedPhotos.count)
//    }
//    
//    // data bytes lenght change
//    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, didChangeBytes bytes: Int) {
//        _updateBytesLenght(bytes)
//    }
//    
//    public func recentlyView(_ recentlyView: SAPhotoRecentlyView, tapItemFor photo: SAPhoto, with sender: Any) {
//        _logger.trace()
//        
//        _showPickerForPreview(photo)
//    }
//}
//
//
//
//// MARK: - SAPhotoPickerDelegate
//
//extension SAPhotoInputView: SAPhotoPickerDelegate {
//    
//    // check whether item can select
//    public func picker(_ picker: SAPhotoPicker, shouldSelectItemFor photo: SAPhoto) -> Bool {
//        // 可以在这里进行数量限制/图片类型限制
//        //
//        // if _selectedPhotoSets.count >= 9 {
//        //     return false // 只能选择9张图片
//        // }
//        // if photo.mediaType != .image {
//        //     return false // 只能选择图片
//        // }
//        return true
//    }
//    public func picker(_ picker: SAPhotoPicker, didSelectItemFor photo: SAPhoto) {
//        _logger.trace()
//        
//        _contentView.scroll(to: photo, animated: true)
//    }
//    
//    // check whether item can deselect
//    public func picker(_ picker: SAPhotoPicker, shouldDeselectItemFor photo: SAPhoto) -> Bool {
//        return true
//    }
//    public func picker(_ picker: SAPhotoPicker, didDeselectItemFor photo: SAPhoto) {
//        _logger.trace()
//        
//    }
//    
//    // data bytes lenght change
//    public func picker(_ picker: SAPhotoPicker, didChangeBytes bytes: Int) {
//        _updateBytesLenght(bytes)
//    }
//    
//    public func picker(_ picker: SAPhotoPicker, canConfrim photos: Array<SAPhoto>) -> Bool {
//        _updatePhotoCount(photos.count)
//        return _sendBarItem.isEnabled
//    }
//    
//    public func picker(_ picker: SAPhotoPicker, willDismiss animated: Bool) {
//        _logger.trace()
//        
//        // 同步
//        _contentView.selectedPhotos = picker.selectedPhotos
//        _contentView.alwaysSelectOriginal = picker.alwaysSelectOriginal
//        
//        _originalBarItem.isSelected = picker.alwaysSelectOriginal
//    }
//    
//    // end
//    public func picker(_ picker: SAPhotoPicker, confrim photos: Array<SAPhoto>) {
//        _logger.trace()
//        
//    }
//    public func picker(_ picker: SAPhotoPicker, cancel photos: Array<SAPhoto>) {
//        _logger.trace()
//        
//    }
}
