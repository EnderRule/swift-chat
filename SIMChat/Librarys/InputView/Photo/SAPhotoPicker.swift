//
//  SAPhotoPicker.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

@objc
public protocol SAPhotoPickerDelegate: UINavigationControllerDelegate {
    
    @objc optional func picker(willDismiss picker: SAPhotoPicker)
    @objc optional func picker(didDismiss picker: SAPhotoPicker)
    
    // MARK: Selection
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    @objc optional func picker(_ picker: SAPhotoPicker, indexOfSelectedItemsFor photo: SAPhoto) -> Int
   
    // check whether item can select
    @objc optional func picker(_ picker: SAPhotoPicker, shouldSelectItemFor photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didSelectItemFor photo: SAPhoto)
    
    // check whether item can deselect
    @objc optional func picker(_ picker: SAPhotoPicker, shouldDeselectItemFor photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didDeselectItemFor photo: SAPhoto)
    
    @objc optional func picker(_ picker: SAPhotoPicker, willDisplayItemOfPreview photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didDisplayItemOfPreview photo: SAPhoto)
    
    // tap item
    @objc optional func picker(_ picker: SAPhotoPicker, tapItemFor photo: SAPhoto, with sender: Any)
    
    @objc optional func picker(_ picker: SAPhotoPicker, toolbarItemsFor context: SAPhotoToolbarContext) -> [UIBarButtonItem]?
    
    @objc optional func picker(_ picker: SAPhotoPicker, didConfrim sender: AnyObject)
    @objc optional func picker(_ picker: SAPhotoPicker, didCancel sender: AnyObject)
}


public class SAPhotoPicker: UIViewController {
    
    public dynamic var allowsMultipleSelection: Bool = true
    
    @objc(delegater)
    public dynamic weak var delegate: SAPhotoPickerDelegate? 
    
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
    
    private dynamic class func _alloc(zone: NSZone) -> AnyObject? {
        let s1 = Selector(String("allocWithZone:"))
        let ret = SAPhotoPickerForImp.perform(s1, with: zone)
        return ret?.takeRetainedValue()
    }
    
    public dynamic init() {
        fatalError("init() not imp")
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not imp")
    }
}

