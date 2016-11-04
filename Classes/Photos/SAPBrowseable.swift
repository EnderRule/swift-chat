//
//  SAPBrowseable.swift
//  SAPhotos
//
//  Created by sagesse on 11/4/16.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

///
/// 可浏览协议
///
@objc public protocol SAPBrowseable {
    
    var browseSize: CGSize { get }
    var browseOrientation: UIImageOrientation  { get }
    
    var browseThumb: SAPProgressiveable? { get }
    var browseContent: SAPProgressiveable? { get }
}
