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
    
    @objc optional func photoPicker(didCancel photoPicker: SAPhotoPicker)
    @objc optional func photoPicker(didFininsh photoPicker: SAPhotoPicker)
}

open class SAPhotoPicker: NSObject {
    
    open weak var delegate: SAPhotoPickerDelegate?
    
    open func show(in viewController: UIViewController) {
        _SAPhotoPickerActivatedInstance = self
        // 授权完成之后再弹出
        SAPhotoLibrary.requestAuthorization { hasPermission in
            DispatchQueue.main.async {
                
                guard hasPermission else {
                    // 授权失败. 或许需要显示错误页面, 因为他可以恢复的
                    return
                }
                let nav = UINavigationController()
                let vc = SAPhotoPickerAlbums()
                
                vc.photoDelegate = self
//            let v1 = UIViewController()
//            let v2 = UIViewController()
//            
//            v1.view.backgroundColor = .random
//            v2.view.backgroundColor = .random
                
                nav.setViewControllers([vc], animated: false)
                
                viewController.present(nav, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoPicker: SAPhotoViewDelegate {
    
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

private var _SAPhotoPickerActivatedInstance: SAPhotoPicker?

