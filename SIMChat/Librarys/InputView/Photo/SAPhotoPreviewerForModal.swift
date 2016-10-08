//
//  SAPhotoPreviewerForModal.swift
//  SIMChat
//
//  Created by sagesse on 10/8/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPreviewerForModal: UINavigationController {
    
    var previewer: SAPhotoPreviewer {
        return _previewer
    }
    
    override var viewControllers: [UIViewController] {
        set {
            _viewControllers = newValue
            if _viewControllers.first === _temp {
                _viewControllers.removeFirst()
            }
            if _viewControllers.first === _previewer {
                _viewControllers.removeFirst()
            }
            return super.viewControllers = [_temp, _previewer] + viewControllers
        }
        get {
            return super.viewControllers
        }
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool {
        let canBack = item !== _previewer.navigationItem
        DispatchQueue.main.async {
            guard !canBack else {
                self.popViewController(animated: true)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
        return canBack
    }

    private lazy var _temp: UIViewController = UIViewController()
    private lazy var _previewer: SAPhotoPreviewer = SAPhotoPreviewer()
    
    private lazy var _viewControllers: [UIViewController] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewControllers = []
    }
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        viewControllers = []
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        viewControllers = []
    }
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        viewControllers = [rootViewController]
    }
}
