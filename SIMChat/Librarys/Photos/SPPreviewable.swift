//
//  SPPreviewable.swift
//  SIMChat
//
//  Created by sagesse on 10/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc public protocol SPPreviewableDelegate: NSObjectProtocol {
    
    func toPreviewable(with item: AnyObject) -> SPPreviewable?
    func fromPreviewable(with item: AnyObject) -> SPPreviewable?
    
    @objc optional func previewable(_ previewable: SPPreviewable, willShowItem item: AnyObject)
    @objc optional func previewable(_ previewable: SPPreviewable, didShowItem item: AnyObject)
}

@objc public protocol SPPreviewable: NSObjectProtocol {
    
    var previewingFrame: CGRect { get }
    
    var previewingContent: UIImage? { get }
    var previewingContentSize: CGSize { get }
    
    var previewingContentMode: UIViewContentMode { get }
    var previewingContentOrientation: UIImageOrientation { get }
}
