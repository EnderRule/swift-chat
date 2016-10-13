//
//  SAPhotoPreviewingContext.swift
//  SIMChat
//
//  Created by sagesse on 10/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
public protocol SAPhotoPreviewingContext: NSObjectProtocol {
    
    var previewingFrame: CGRect { get }
    var previewingContentMode: UIViewContentMode { get }
    
    var previewingImage: UIImage? { get }
}

@objc
public protocol SAPhotoPreviewingDelegate: NSObjectProtocol {
    
    func previewingContext(with item: AnyObject) -> SAPhotoPreviewingContext?
    
    @objc optional func previewingContext(_ previewingContext: SAPhotoPreviewingContext, willShowItem item: AnyObject)
    @objc optional func previewingContext(_ previewingContext: SAPhotoPreviewingContext, didShowItem item: AnyObject)
}
