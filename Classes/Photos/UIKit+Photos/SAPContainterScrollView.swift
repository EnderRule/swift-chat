//
//  SAPContainterScrollView.swift
//  SAPhotos
//
//  Created by sagesse on 03/11/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

internal class SAPContainterScrollView: UIScrollView {
    
    override var contentInset: UIEdgeInsets {
        set { return ext_contentInset = newValue }
        get { return .zero }
    }
    override var scrollIndicatorInsets: UIEdgeInsets {
        set { return ext_scrollIndicatorInsets = newValue }
        get { return .zero }
    }
    
    var ext_contentInset: UIEdgeInsets = .zero
    var ext_scrollIndicatorInsets: UIEdgeInsets = .zero
}
