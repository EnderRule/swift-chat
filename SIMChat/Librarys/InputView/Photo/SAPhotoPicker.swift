//
//  SAPhotoPicker.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


open class SAPhotoPicker: NSObject {
    
    open func show(in viewController: UIViewController) {
        // 授权完成之后再弹出
        SAPhotoLibrary.requestAuthorization { hasPermission in
            DispatchQueue.main.async {
                guard hasPermission else {
                    // 授权失败. 或许需要显示错误页面, 因为他可以恢复的
                    return
                }
                let nav = UINavigationController()
                let vc = SAPhotoPickerAlbums()
                
//            let v1 = UIViewController()
//            let v2 = UIViewController()
//            
//            v1.view.backgroundColor = .random
//            v2.view.backgroundColor = .random
                
                nav.setViewControllers([vc], animated: false)
                
                viewController.present(nav, animated: true, completion: nil)
            }
        }
    }
}
