//
//  SAPhotoPreviewingAnimator.swift
//  SIMChat
//
//  Created by sagesse on 10/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPreviewingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    static func pop(item: AnyObject, from: SAPhotoPreviewingDelegate, to: SAPhotoPreviewingDelegate) -> SAPhotoPreviewingAnimator? {
        let animator = SAPhotoPreviewingAnimator(item: item, from: from, to: to)
        animator?.isPush = false
        return animator
    }
    static func push(item: AnyObject, from: SAPhotoPreviewingDelegate, to: SAPhotoPreviewingDelegate) -> SAPhotoPreviewingAnimator? {
        let animator = SAPhotoPreviewingAnimator(item: item, from: from, to: to)
        animator?.isPush = true
        return animator
    }
    
    var isPush: Bool = false
    
    var item: AnyObject
    var toPhotoView: UIView
    var fromPhotoView: UIView
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        //return 0.35
        return 1
    }

    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let bakcgroundView = UIView()
        let view = fromPhotoView.snapshotView(afterScreenUpdates: true)
        
//        let fromPreviewing = fromDelegate?.sourceView(of: item)
//        let toPreviewing = toDelegate?.sourceView(of: item)
        
//        let fromVC = transitionContext.viewController(forKey: .from)
//        let toVC = transitionContext.viewController(forKey: .to)
//        
////        let fromView = transitionContext.view(forKey: .from)
////        let toView = transitionContext.view(forKey: .to)
//        
        
        //添加toView到上下文
        if let toView = toView {
            //containerView.insertSubview(toView, belowSubview: fromView)
            containerView.addSubview(toView)
        }
        // 添加快照到上下文
        if let view = view {
            containerView.addSubview(bakcgroundView)
            containerView.addSubview(view)
        }
        
//        toVC?.view.transform = CGAffineTransform(translationX: -320, y: -568)
        
        let fromRect = containerView.convert(fromPhotoView.frame, from: fromPhotoView.superview)
        let toRect = containerView.convert(toPhotoView.frame, from: toPhotoView.superview)
        
        view?.frame = fromRect
        bakcgroundView.frame = containerView.bounds
        //view?.backgroundColor = toView?.backgroundColor?.withAlphaComponent(0)
        
        if isPush {
            fromPhotoView.isHidden = true
            toPhotoView.isHidden = true
            
            bakcgroundView.alpha = 0
            bakcgroundView.backgroundColor = toView?.backgroundColor
        
        } else {
            fromPhotoView.isHidden = true
            toPhotoView.isHidden = false
            
            bakcgroundView.alpha = 1
            bakcgroundView.backgroundColor = fromView?.backgroundColor
        }
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            
            view?.frame = toRect
            if self.isPush {
                bakcgroundView.alpha = 1
            } else {
                bakcgroundView.alpha = 0
            }
            
            
            //fromVC?.view.transform = CGAffineTransform(translationX: 320, y: 568)
            //toVC?.view.transform = .identity
            
        }, completion: { b in
 
            self.fromPhotoView.isHidden = false
            self.toPhotoView.isHidden = false
            
            bakcgroundView.removeFromSuperview()
            view?.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    private init?(item: AnyObject, from: SAPhotoPreviewingDelegate, to: SAPhotoPreviewingDelegate) {
        guard let fp = from.sourceView(of: item), let tp = to.sourceView(of: item) else {
            return nil
        }
        self.item = item
        self.toPhotoView = tp
        self.fromPhotoView = fp
        
        super.init()
    }
    
}
