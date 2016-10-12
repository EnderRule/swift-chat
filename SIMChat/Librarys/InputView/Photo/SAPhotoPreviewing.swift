//
//  SAPhotoPreviewing.swift
//  SIMChat
//
//  Created by sagesse on 10/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public protocol SAPhotoPreviewing: NSObjectProtocol {
}

public protocol SAPhotoPreviewingDelegate: NSObjectProtocol {
    
    func sourceView(of item: AnyObject) -> UIView?
    
}

