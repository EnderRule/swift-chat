//
//  UIImage+Photos.swift
//  SAPhotos
//
//  Created by sagesse on 31/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal extension UIImage {
    static func sap_init(named: String) -> UIImage? {
        return UIImage(named: named, in: SAPPicker.bundle, compatibleWith: nil)
    }
}
