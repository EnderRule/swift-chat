//
//  SAPhotoPicker.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

///
/// 图片选择器预览选项
///
@objc public class SAPhotoPickerOptions: NSObject {
    
    public init(album: SAPhotoAlbum, default: SAPhoto? = nil, ascending: Bool = true) {
        super.init()
        self.ascending = ascending
        self.`default` = `default`
        self.album = album
    }
    public init(photos: Array<SAPhoto>, default: SAPhoto? = nil, ascending: Bool = true) {
        super.init()
        self.ascending = ascending
        self.`default` = `default`
        self.photos = photos
    }
    
    public var `default`: SAPhoto?
    public var ascending: Bool = true
    
    public var album: SAPhotoAlbum?
    public var photos: Array<SAPhoto>?
    
    public weak var previewingDelegate: SAPhotoPreviewableDelegate?
}

///
/// 图片选择器代理
///
@objc public protocol SAPhotoPickerDelegate: UINavigationControllerDelegate {
    
    // check whether item can select
    @objc optional func picker(_ picker: SAPhotoPicker, shouldSelectItemFor photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didSelectItemFor photo: SAPhoto)
    
    // check whether item can deselect
    @objc optional func picker(_ picker: SAPhotoPicker, shouldDeselectItemFor photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didDeselectItemFor photo: SAPhoto)
    
    // data bytes lenght change
    @objc optional func picker(_ picker: SAPhotoPicker, didChangeBytes bytes: Int)
    
    // end
    @objc optional func picker(_ picker: SAPhotoPicker, didConfrim photos: Array<SAPhoto>)
    @objc optional func picker(_ picker: SAPhotoPicker, didCancel photos: Array<SAPhoto>)
    
    // tap item
    @objc optional func picker(_ picker: SAPhotoPicker, tapItemFor photo: SAPhoto, with sender: Any)
}


///
/// 图片选择器
///
@objc public class SAPhotoPicker: UIViewController {
    
    /// 是否允许编辑图片, 默认值为false
    public dynamic var allowsEditing: Bool
    /// 是否允许多选, 默认值为true
    public dynamic var allowsMultipleSelection: Bool
    
    /// 选中的图片
    public dynamic var selectedPhotos: Array<SAPhoto>
    /// 是否使用原图, 默认值为false
    public dynamic var alwaysUseOriginalImage: Bool
    
    /// 选择器的代理
    public dynamic weak var delegate: SAPhotoPickerDelegate?  {
        @objc(delegater) get { fatalError() }
        @objc(setDelegater:) set { fatalError() }
    }
    
    
    ///
    /// 显示一个相册
    ///
    /// - parameter album: 相册
    /// - parameter animated: 是否使用转场动画
    ///
    public dynamic func pick(with album: SAPhotoAlbum, animated: Bool) {
        fatalError()
    }
    ///
    /// 显示预览
    ///
    /// - parameter options: 一些选项
    /// - parameter animated: 是否使用转场动画
    ///
    public dynamic func preview(with options: SAPhotoPickerOptions, animated: Bool) {
        fatalError()
    }
    
    ///
    /// 创建一个图片选择器, 默认显示第一个相册
    ///
    public dynamic init() {
        fatalError()
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    ///
    /// 创建一个图片选择器, 并显示指定的相册
    ///
    /// NOTE: 和pick(with:)不同的时, 点击返回将dismiss
    ///
    public dynamic convenience init(pick album: SAPhotoAlbum) {
        fatalError()
    }
    ///
    /// 创建一个图片选择器(预览)
    ///
    /// NOTE: 和preview(with:)不同的时, 点击返回将dismiss
    ///
    public dynamic convenience init(preview options: SAPhotoPickerOptions) {
        fatalError()
    }
    
    /// 类初始化
    public override class func initialize() {
        // 替换类方法
        guard let metaClass = objc_getMetaClass(NSStringFromClass(self).cString(using: .utf8)) as? AnyClass else {
            return
        }
        let s1 = Selector(String("allocWithZone:"))
        let s2 = Selector(String("_allocWithZone:"))
        
        let m1 = class_getClassMethod(self, s1)
        let m2 = class_getClassMethod(self, s2)
        
        class_replaceMethod(metaClass, s1, method_getImplementation(m2), method_getTypeEncoding(m1))
    }
    /// 创建方法
    private dynamic class func _alloc(zone: NSZone) -> AnyObject? {
        // 使用的是类簇
        let s1 = Selector(String("allocWithZone:"))
        let ret = SAPhotoPickerForImp.perform(s1, with: zone)
        return ret?.takeRetainedValue()
    }
}

