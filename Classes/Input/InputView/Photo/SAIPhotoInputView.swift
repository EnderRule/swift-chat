//
//  SAIPhotoInputView.swift
//  SAC
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


// # TODO
// [x] SAIPhotoView - 异步加载
// [ ] SAIPhotoView - 渐进式解码
// [x] SAIPhotoView - 选择顺序
// [x] SAIPhotoView - 选中支持
// [x] SAIPhotoView - 选中高亮支持
// [x] SAIPhotoView - SelectView悬停
// [ ] SAIPhotoView - iClound图片下载进度显示
// [ ] SAIPhotoView - iClound图标
// [x] SAIPhotoView - 媒体类型图标
// [x] SAIPhotoAlbumStackView - 空相册图标
// [x] SAIPhotoAlbumStackView - 相册类型图标
// [ ] SAIPhotoBrowser - 实现
// [ ] SAIPhotoBrowser - 错误显示(无权限显示)
// [ ] SAIPhotoBrowser - 图片更新通知
// [ ] SAIPhotoBrowser - 加载进度
// [ ] SAIPhotoBrowser - 视频
// [ ] SAIPhotoBrowser - 音频
// [ ] SAIPhotoBrowser - GIF
// [x] SAIPhotoBrowserView - 横屏支持
// [ ] SAIPhotoBrowserView - 转屏后的恢复图片中心位置
// [x] SAIPhotoBrowserView - 图片缩放
// [x] SAIPhotoBrowserView - 图片旋转
// [x] SAIPhotoBrowserView - 双击放大
// [x] SAIPhotoBrowserView - 双击放大(双击的地方要居中)
// [ ] SAIPhotoBrowserView - iClound图片下载进度显示
// [x] SAIPhotoPicker - 相册列表
// [x] SAIPhotoPicker - 图片列表
// [x] SAIPhotoPicker - 图片预览
// [x] SAIPhotoPicker - 选择原图(文件大小)
// [x] SAIPhotoPicker - 拦截返回事件
// [x] SAIPhotoPicker - 默认barItem
// [ ] SAIPhotoPicker - 支持Moments模式
// [x] SAIPhotoPickerForAlbums - 图片变更通知处理
// [x] SAIPhotoPickerForAlbums - 空相册处理
// [x] SAIPhotoPickerForAlbums - 默认显示album
// [ ] SAIPhotoPickerForAssets - 快速滚动时有性能问题
// [x] SAIPhotoPickerForAssets - 数量
// [x] SAIPhotoPickerForAssets - 单选支持
// [x] SAIPhotoPickerForAssets - 选中
// [x] SAIPhotoPickerForAssets - 批量选中
// [x] SAIPhotoPickerForAssets - 图片变更通知处理(多张新增、多张删除、多张改变、同时改变、删除Album)
// [x] SAIPhotoPickerForAssets - 图片变更时的选中问题(检查图片是否被删除, 如果被删除将取消选中)
// [x] SAIPhotoPickerForAssets - UIToolbar支持
// [x] SAIPhotoPickerForAssets - 预览的item超出visableCells时的处理
// [ ] SAIPhotoPickerForAssets - 跨界面转屏崩溃
// [x] SAIPhotoPickerForAssets - 默认显示在底部
// [x] SAIPhotoPickerForAssets - 底部显示图片数量
// [ ] SAIPhotoPickerForAssets - 当有大量的图片变更时, 可能会导致应用卡死
// [x] SAIPhotoPickerForPreviewer - 单选支持
// [x] SAIPhotoPickerForPreviewer - 转场动画(弹出)
// [x] SAIPhotoPickerForPreviewer - 横屏支持
// [ ] SAIPhotoPickerForPreviewer - 手势(下拉)隐藏
// [x] SAIPhotoPickerForPreviewer - 图片变更通知处理
// [x] SAIPhotoPickerForPreviewer - 选中事件处理
// [x] SAIPhotoPickerForPreviewer - 自定义toolbar
// [x] SAIPhotoRecentlyView - 分离实现
// [x] SAIPhotoRecentlyView - 错误显示 
// [x] SAIPhotoRecentlyView - 横屏支持
// [x] SAIPhotoRecentlyView - 图片变更(多张新增、多张删除、多张改变、同时改变)
// [x] SAIPhotoRecentlyView - 图片变更时的选中问题(检查图片是否被删除, 如果被删除将取消选中)
// [ ] SAIPhotoRecentlyView - 大小变更处理(宽/高)
// [x] SAIPhotoToolbar - Item重用
// [x] SAIPhotoPreviewableAnimator - 图片变更动画(渐变)
// [x] SAIPhotoPreviewableAnimator - 图片旋转动画
// [x] SAIPhotoPreviewableAnimator - contentMode变更动画
// [ ] SAIPhotoPreviewableAnimator - 移动选择视图
// [x] SAIPhotoInputView - 横屏支持
// [x] SAIPhotoInputView - 预览选中的图片
// [ ] * - 发送图片(读取)


@objc
public protocol SAIPhotoInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
}

public class SAIPhotoInputView: UIView {
    
    public var allowsMultipleSelection: Bool = true {
        didSet {
            //_picker?.allowsMultipleSelection = allowsMultipleSelection
            //_contentView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    public weak var delegate: SAIPhotoInputViewDelegate?
        
        
    public override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
//    func toolbarItems(for context: SAIPhotoToolbarContext) -> [UIBarButtonItem]? {
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
//        _pickBarItem = SAIPhotoBarItem(title: "相册", type: .normal, target: self, action: #selector(pickerHandler(_:)))
//        _editBarItem = SAIPhotoBarItem(title: "编辑", type: .normal, target: self, action: #selector(onEditor(_:)))
//        _sendBarItem = SAIPhotoBarItem(title: "发送", type: .send, target: self, action: #selector(onSendForPicker(_:)))
//        _originalBarItem = SAIPhotoBarItem(title: "原图", type: .original, target: self, action: #selector(onChangeOriginal(_:)))
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
//    fileprivate lazy var _selectedPhotos: Array<SAIPhoto> = []
//    fileprivate lazy var _selectedPhotoSets: Set<SAIPhoto> = []
//    
//    fileprivate var _pickBarItem: SAIPhotoBarItem!
//    fileprivate var _editBarItem: SAIPhotoBarItem!
//    fileprivate var _originalBarItem: SAIPhotoBarItem!
//    fileprivate var _sendBarItem: SAIPhotoBarItem!
//    fileprivate var _spaceBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//    
//    fileprivate lazy var _tabbar: SAIPhotoToolbar = SAIPhotoToolbar()
//    fileprivate lazy var _contentView: SAIPhotoRecentlyView = SAIPhotoRecentlyView()
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
//extension SAIPhotoInputView {
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
//    func confrim(photos: Array<SAIPhoto>) {
//        _logger.trace()
//        
////        // 清除所有选中
////        _contentView.selectedPhotos = []
////        _updatePhotoCount()
//    }
//    func cancel(photo: Array<SAIPhoto>) {
//        _logger.trace()
//        
////        // 清除所有选中
////        _contentView.selectedPhotos = []
////        _updatePhotoCount()
//    }
//    
//}
//
//fileprivate extension SAIPhotoInputView {
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
//            _originalBarItem.title = "原图(\(SAIPhotoFormatBytesLenght(lenght)))"
//        }
//    }
//    
//    /// 显示图片选择器
//    func _showPicker() {
//        guard let window = UIApplication.shared.delegate?.window else {
//            return // no window, is unknow error
//        }
//        let picker = SAIPhotoPicker()
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
//    func _showPickerForPreview(_ photo: SAIPhoto) {
//        guard let window = UIApplication.shared.delegate?.window else {
//            return // no window, is unknow error
//        }
//        let options = SAIPhotoPickerOptions(album: photo.album, default: photo, ascending: false)
//        let picker = SAIPhotoPicker(preview: options)
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
//// MARK: - SAIPhotoRecentlyViewDelegate
//
//extension SAIPhotoInputView: SAIPhotoRecentlyViewDelegate {
//    
//    // check whether item can select
//    public func recentlyView(_ recentlyView: SAIPhotoRecentlyView, shouldSelectItemFor photo: SAIPhoto) -> Bool {
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
//    public func recentlyView(_ recentlyView: SAIPhotoRecentlyView, didSelectItemFor photo: SAIPhoto) {
//        _logger.trace()
//        
//        _updatePhotoCount(recentlyView.selectedPhotos.count)
//    }
//    
//    // check whether item can deselect
//    public func recentlyView(_ recentlyView: SAIPhotoRecentlyView, shouldDeselectItemFor photo: SAIPhoto) -> Bool {
//        return true
//    }
//    public func recentlyView(_ recentlyView: SAIPhotoRecentlyView, didDeselectItemFor photo: SAIPhoto) {
//        _logger.trace()
//        
//        _updatePhotoCount(recentlyView.selectedPhotos.count)
//    }
//    
//    // data bytes lenght change
//    public func recentlyView(_ recentlyView: SAIPhotoRecentlyView, didChangeBytes bytes: Int) {
//        _updateBytesLenght(bytes)
//    }
//    
//    public func recentlyView(_ recentlyView: SAIPhotoRecentlyView, tapItemFor photo: SAIPhoto, with sender: Any) {
//        _logger.trace()
//        
//        _showPickerForPreview(photo)
//    }
//}
//
//
//
//// MARK: - SAIPhotoPickerDelegate
//
//extension SAIPhotoInputView: SAIPhotoPickerDelegate {
//    
//    // check whether item can select
//    public func picker(_ picker: SAIPhotoPicker, shouldSelectItemFor photo: SAIPhoto) -> Bool {
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
//    public func picker(_ picker: SAIPhotoPicker, didSelectItemFor photo: SAIPhoto) {
//        _logger.trace()
//        
//        _contentView.scroll(to: photo, animated: true)
//    }
//    
//    // check whether item can deselect
//    public func picker(_ picker: SAIPhotoPicker, shouldDeselectItemFor photo: SAIPhoto) -> Bool {
//        return true
//    }
//    public func picker(_ picker: SAIPhotoPicker, didDeselectItemFor photo: SAIPhoto) {
//        _logger.trace()
//        
//    }
//    
//    // data bytes lenght change
//    public func picker(_ picker: SAIPhotoPicker, didChangeBytes bytes: Int) {
//        _updateBytesLenght(bytes)
//    }
//    
//    public func picker(_ picker: SAIPhotoPicker, canConfrim photos: Array<SAIPhoto>) -> Bool {
//        _updatePhotoCount(photos.count)
//        return _sendBarItem.isEnabled
//    }
//    
//    public func picker(_ picker: SAIPhotoPicker, willDismiss animated: Bool) {
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
//    public func picker(_ picker: SAIPhotoPicker, confrim photos: Array<SAIPhoto>) {
//        _logger.trace()
//        
//    }
//    public func picker(_ picker: SAIPhotoPicker, cancel photos: Array<SAIPhoto>) {
//        _logger.trace()
//        
//    }
}
