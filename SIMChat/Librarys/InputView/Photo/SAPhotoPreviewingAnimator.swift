//
//  SAPhotoPreviewingAnimator.swift
//  SIMChat
//
//  Created by sagesse on 10/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPreviewingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var item: AnyObject
//    var toPhotoView: UIView
//    var fromPhotoView: UIView
    
    var toContext: SAPhotoPreviewingContext
    var fromContext: SAPhotoPreviewingContext
    
    weak var toDelegate: SAPhotoPreviewingDelegate?
    weak var fromDelegate: SAPhotoPreviewingDelegate?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError()
//        let containerView = transitionContext.containerView
//        let fromView = transitionContext.view(forKey: .from)
//        let toView = transitionContext.view(forKey: .to)
//        
//        let bakcgroundView = UIView()
//        let view = fromPhotoView.snapshotView(afterScreenUpdates: true)
//        
////        let fromContext = fromDelegate?.sourceView(of: item)
////        let toContext = toDelegate?.sourceView(of: item)
//        
////        let fromVC = transitionContext.viewController(forKey: .from)
////        let toVC = transitionContext.viewController(forKey: .to)
////        
//////        let fromView = transitionContext.view(forKey: .from)
//////        let toView = transitionContext.view(forKey: .to)
////        
//        
//        //添加toView到上下文
//        if let toView = toView {
//            //containerView.insertSubview(toView, belowSubview: fromView)
//            containerView.addSubview(toView)
//        }
//        // 添加快照到上下文
//        if let view = view {
//            containerView.addSubview(bakcgroundView)
//            containerView.addSubview(view)
//        }
//        
////        toVC?.view.transform = CGAffineTransform(translationX: -320, y: -568)
//        
//        let fromRect = containerView.convert(fromPhotoView.frame, from: fromPhotoView.superview)
//        let toRect = containerView.convert(toPhotoView.frame, from: toPhotoView.superview)
//        
//        view?.frame = fromRect
//        bakcgroundView.frame = containerView.bounds
//        //view?.backgroundColor = toView?.backgroundColor?.withAlphaComponent(0)
//        
//        if isPush {
//            fromPhotoView.isHidden = true
//            toPhotoView.isHidden = true
//            
//            bakcgroundView.alpha = 0
//            bakcgroundView.backgroundColor = toView?.backgroundColor
//        
//        } else {
//            fromPhotoView.isHidden = true
//            toPhotoView.isHidden = false
//            
//            bakcgroundView.alpha = 1
//            bakcgroundView.backgroundColor = fromView?.backgroundColor
//        }
//        
//        
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
//            
//            view?.frame = toRect
//            if self.isPush {
//                bakcgroundView.alpha = 1
//            } else {
//                bakcgroundView.alpha = 0
//            }
//            
//            
//            //fromVC?.view.transform = CGAffineTransform(translationX: 320, y: 568)
//            //toVC?.view.transform = .identity
//            
//        }, completion: { b in
// 
//            self.fromPhotoView.isHidden = false
//            self.toPhotoView.isHidden = false
//            
//            bakcgroundView.removeFromSuperview()
//            view?.removeFromSuperview()
//            
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
    }
    
    init?(item: AnyObject, from: SAPhotoPreviewingDelegate, to: SAPhotoPreviewingDelegate) {
        guard let fp = from.previewingContext(with: item), let tp = to.previewingContext(with: item) else {
            return nil
        }
        self.item = item
        self.toContext = tp
        self.fromContext = fp
        super.init()
        self.toDelegate = to
        self.fromDelegate = from
    }
    
    static func pop(item: AnyObject, from: SAPhotoPreviewingDelegate, to: SAPhotoPreviewingDelegate) -> SAPhotoPreviewingAnimator? {
        return SAPhotoPreviewingContextPopAnimator(item: item, from: from, to: to)
    }
    static func push(item: AnyObject, from: SAPhotoPreviewingDelegate, to: SAPhotoPreviewingDelegate) -> SAPhotoPreviewingAnimator? {
        return SAPhotoPreviewingContextPushAnimator(item: item, from: from, to: to)
    }
}

internal class SAPhotoPreviewingContextPushAnimator: SAPhotoPreviewingAnimator {
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //_logger.trace()
        
        let containerView = transitionContext.containerView
        //let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let previewView = SAPhotoPreviewingView()
        let bakcgroundView = UIView()
        
        //添加toView到上下文
        if let toView = toView {
            //containerView.insertSubview(toView, belowSubview: fromView)
            containerView.addSubview(toView)
        }
        // 添加快照到上下文
        containerView.addSubview(bakcgroundView)
        containerView.addSubview(previewView)
        
        let fromRect = containerView.convert(fromContext.previewingFrame, from: containerView.window)
        let toRect = containerView.convert(toContext.previewingFrame, from: containerView.window)
        
        previewView.previewing = fromContext
        previewView.frame = fromRect
        previewView.layoutIfNeeded()
        
        bakcgroundView.alpha = 0
        bakcgroundView.frame = containerView.bounds
        bakcgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bakcgroundView.backgroundColor = toView?.backgroundColor
        
        toView?.isHidden = true
        
        self.toDelegate?.previewingContext?(self.toContext, willShowItem: self.item)
        self.fromDelegate?.previewingContext?(self.fromContext, willShowItem: self.item)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 15, options: .curveEaseInOut, animations: {

            previewView.previewing = self.toContext
            previewView.frame = toRect
            previewView.layoutIfNeeded()
            bakcgroundView.alpha = 1
            
        }, completion: { b in
            
            toView?.isHidden = false
            previewView.removeFromSuperview()
            bakcgroundView.removeFromSuperview()
            
            self.toDelegate?.previewingContext?(self.toContext, didShowItem: self.item)
            self.fromDelegate?.previewingContext?(self.fromContext, didShowItem: self.item)
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
internal class SAPhotoPreviewingContextPopAnimator: SAPhotoPreviewingAnimator {
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //_logger.trace()
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let previewView = SAPhotoPreviewingView()
        let bakcgroundView = UIView()
        
        //添加toView到上下文
        if let toView = toView {
            //containerView.insertSubview(toView, belowSubview: fromView)
            containerView.addSubview(toView)
        }
        // 添加快照到上下文
        containerView.addSubview(bakcgroundView)
        containerView.addSubview(previewView)
        
        let fromRect = containerView.convert(fromContext.previewingFrame, from: containerView.window)
        let toRect = containerView.convert(toContext.previewingFrame, from: containerView.window)
        
        previewView.previewing = fromContext
        previewView.frame = fromRect
        previewView.layoutIfNeeded()
        
        bakcgroundView.alpha = 1
        bakcgroundView.frame = containerView.bounds
        bakcgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bakcgroundView.backgroundColor = fromView?.backgroundColor
        
        fromView?.isHidden = true
        
        self.toDelegate?.previewingContext?(self.toContext, willShowItem: self.item)
        self.fromDelegate?.previewingContext?(self.fromContext, willShowItem: self.item)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseOut, animations: {

            previewView.previewing = self.toContext
            previewView.frame = toRect
            previewView.layoutIfNeeded()
            bakcgroundView.alpha = 0
            
        }, completion: { b in
            
            fromView?.isHidden = false
            previewView.removeFromSuperview()
            bakcgroundView.removeFromSuperview()
            
            self.toDelegate?.previewingContext?(self.toContext, didShowItem: self.item)
            self.fromDelegate?.previewingContext?(self.fromContext, didShowItem: self.item)

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
}
