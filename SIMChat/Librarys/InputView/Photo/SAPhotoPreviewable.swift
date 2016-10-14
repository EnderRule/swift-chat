//
//  SAPhotoPreviewable.swift
//  SIMChat
//
//  Created by sagesse on 10/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
public protocol SAPhotoPreviewable: NSObjectProtocol {
    
    var previewingFrame: CGRect { get }
    
    var previewingContent: SAPhotoProgressiveable? { get }
    var previewingContentSize: CGSize { get }
    var previewingContentOrientation: UIImageOrientation { get }
    var previewingContentMode: UIViewContentMode { get }

    var previewingContentVisableSize: CGSize { get }
}

@objc
public protocol SAPhotoPreviewableDelegate: NSObjectProtocol {
    
    func previewable(with item: AnyObject) -> SAPhotoPreviewable?
    
    @objc optional func previewable(_ previewable: SAPhotoPreviewable, willShowItem item: AnyObject)
    @objc optional func previewable(_ previewable: SAPhotoPreviewable, didShowItem item: AnyObject)
}
