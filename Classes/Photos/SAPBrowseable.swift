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
    
    var browseType: SAPBrowseableType { get }
    
    var browseSize: CGSize { get }
    var browseOrientation: UIImageOrientation  { get }
    
    var browseImage: Progressiveable? { get }
    var browseContent: Progressiveable? { get }  // 这个参数只用于视频和音频
}

///
/// 可浏览对象类型
///
@objc public enum SAPBrowseableType: Int {
    case Image
    case Video
    case Audio
}
