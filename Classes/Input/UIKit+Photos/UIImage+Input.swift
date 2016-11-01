//
//  UIImage+Photos.swift
//  SAIPhotos
//
//  Created by sagesse on 31/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal extension UIImage {
    static func sai_init(named: String) -> UIImage? {
        return UIImage(named: named, in: _frameworkMainBundle, compatibleWith: nil)
    }
}

private weak var _frameworkMainBundle: Bundle? = Bundle(identifier: "SA.SAInput")
