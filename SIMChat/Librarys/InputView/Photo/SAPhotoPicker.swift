//
//  SAPhotoPicker.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
public protocol SAPhotoPickerDelegate: NSObjectProtocol {
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, indexOfSelectedItem photo: SAPhoto) -> Int
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, isSelectedOfItem photo: SAPhoto) -> Bool
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, previewItem photo: SAPhoto, in view: UIView)
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, shouldSelectItem photo: SAPhoto) -> Bool
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, didSelectItem photo: SAPhoto)
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, shouldDeselectItem photo: SAPhoto) -> Bool
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, didDeselectItem photo: SAPhoto)
    
    @objc optional func photoPicker(willShow photoPicker: SAPhotoPicker)
    @objc optional func photoPicker(didShow photoPicker: SAPhotoPicker)
    
    @objc optional func photoPicker(didDismiss photoPicker: SAPhotoPicker)
}

open class SAPhotoPicker: NSObject {
    
    
    open var tintColor: UIColor! {
        willSet {
            navgationController?.view.tintColor = tintColor
        }
    }
    
    /// 工具栏Items, 如果为nil则不显示
    open var toolbarItems: [UIBarButtonItem]? {
        willSet {
            rootViewController?.toolbarItems = newValue
        }
    }
    
    open weak var delegate: SAPhotoPickerDelegate?
    
    ///
    /// 显示图片选择器
    ///
    /// - parameter viewController: present的位置
    ///
    open func show(in viewController: UIViewController) {
        _logger.trace()
        
        // 授权完成之后再弹出
        SAPhotoLibrary.requestAuthorization { hasPermission in
            DispatchQueue.main.async {
                
                guard hasPermission else {
                    // 授权失败. 或许需要显示错误页面, 因为他可以恢复的
                    return
                }
                let nav = UINavigationController()
                let albumsVC = SAPhotoPickerAlbums()
                
                albumsVC.picker = self
                albumsVC.toolbarItems = self.toolbarItems
                
                var viewControllers: [UIViewController] = [albumsVC]
                
                if let album = albumsVC.albums.first {
                    let picker = albumsVC.makeAssetsPicker(with: album)
                    picker.scrollsToBottomOfLoad = true
                    viewControllers.append(picker)
                }
                
                nav.view.tintColor = self.tintColor
                nav.setViewControllers(viewControllers, animated: false)
                
                self.onWillShow(albumsVC)
                self.rootViewController = albumsVC
                self.navgationController = nav
                viewController.present(nav, animated: true) {
                    self.onDidShow(albumsVC)
                }
            }
        }
    }
    ///
    /// 隐藏
    ///
    open func dismiss() {
        _logger.trace()
        
        navgationController?.dismiss(animated: true, completion: nil)
    }
    
    weak var rootViewController: SAPhotoPickerAlbums?
    weak var navgationController: UINavigationController?
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoPicker: SAPhotoViewDelegate {
    
    func onWillShow(_ sender: Any) {
        delegate?.photoPicker?(willShow: self)
    }
    func onDidShow(_ sender: Any) {
        delegate?.photoPicker?(didShow: self)
    }
    
    func onDidDismiss(_ sender: Any) {
        delegate?.photoPicker?(didDismiss: self)
    }
    
    func photoView(_ photoView: SAPhotoView, previewItem photo: SAPhoto) {
        delegate?.photoPicker?(self, previewItem: photo, in: photoView)
    }
    
    func photoView(_ photoView: SAPhotoView, indexOfSelectedItem photo: SAPhoto) -> Int {
        return delegate?.photoPicker?(self, indexOfSelectedItem: photo) ?? 0
    }
    func photoView(_ photoView: SAPhotoView, isSelectedOfItem photo: SAPhoto) -> Bool{
        return delegate?.photoPicker?(self, isSelectedOfItem: photo) ?? true
    }
    
    func photoView(_ photoView: SAPhotoView, shouldSelectItem photo: SAPhoto) -> Bool {
        return delegate?.photoPicker?(self, shouldSelectItem: photo) ?? true
    }
    func photoView(_ photoView: SAPhotoView, shouldDeselectItem photo: SAPhoto) -> Bool {
        return delegate?.photoPicker?(self, shouldDeselectItem: photo) ?? true
    }
    
    func photoView(_ photoView: SAPhotoView, didSelectItem photo: SAPhoto) {
        delegate?.photoPicker?(self, didSelectItem: photo)
    }
    func photoView(_ photoView: SAPhotoView, didDeselectItem photo: SAPhoto)  {
        delegate?.photoPicker?(self, didDeselectItem: photo)
    }
}

