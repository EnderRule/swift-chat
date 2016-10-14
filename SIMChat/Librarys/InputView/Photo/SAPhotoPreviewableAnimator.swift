//
//  SAPhotoPreviewableAnimator.swift
//  SIMChat
//
//  Created by sagesse on 10/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public class SAPhotoPreviewableAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var item: AnyObject
    
    var toContext: SAPhotoPreviewable
    var fromContext: SAPhotoPreviewable
    
    weak var toDelegate: SAPhotoPreviewableDelegate?
    weak var fromDelegate: SAPhotoPreviewableDelegate?
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // is empty
    }
    
    init?(item: AnyObject, from: SAPhotoPreviewableDelegate, to: SAPhotoPreviewableDelegate) {
        guard let fp = from.previewable(with: item), let tp = to.previewable(with: item) else {
            return nil
        }
        self.item = item
        self.toContext = tp
        self.fromContext = fp
        super.init()
        self.toDelegate = to
        self.fromDelegate = from
    }
    
    public static func pop(item: AnyObject, from: SAPhotoPreviewableDelegate, to: SAPhotoPreviewableDelegate) -> SAPhotoPreviewableAnimator? {
        return SAPhotoPreviewablePopAnimator(item: item, from: from, to: to)
    }
    public static func push(item: AnyObject, from: SAPhotoPreviewableDelegate, to: SAPhotoPreviewableDelegate) -> SAPhotoPreviewableAnimator? {
        return SAPhotoPreviewablePushAnimator(item: item, from: from, to: to)
    }
}

internal class SAPhotoPreviewablePushAnimator: SAPhotoPreviewableAnimator {
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //_logger.trace()
        
        let containerView = transitionContext.containerView
        //let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let previewView = SAPhotoPreviewableView()
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
        
        self.fromDelegate?.previewable?(self.fromContext, willShowItem: self.item)
        self.toDelegate?.previewable?(self.toContext, willShowItem: self.item)
        
        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 15, options: .curveEaseInOut, animations: {

            previewView.previewing = self.toContext
            previewView.frame = toRect
            previewView.layoutIfNeeded()
            bakcgroundView.alpha = 1
            
        }, completion: { b in
            
            toView?.isHidden = false
            previewView.removeFromSuperview()
            bakcgroundView.removeFromSuperview()
            
            self.toDelegate?.previewable?(self.toContext, didShowItem: self.item)
            self.fromDelegate?.previewable?(self.fromContext, didShowItem: self.item)
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
internal class SAPhotoPreviewablePopAnimator: SAPhotoPreviewableAnimator {
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //_logger.trace()
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let previewView = SAPhotoPreviewableView()
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
        
        self.fromDelegate?.previewable?(self.fromContext, willShowItem: self.item)
        self.toDelegate?.previewable?(self.toContext, willShowItem: self.item)
        
        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            
            previewView.previewing = self.toContext
            previewView.frame = toRect
            previewView.layoutIfNeeded()
            bakcgroundView.alpha = 0
            
        }, completion: { b in
            
            fromView?.isHidden = false
            previewView.removeFromSuperview()
            bakcgroundView.removeFromSuperview()
            
            self.toDelegate?.previewable?(self.toContext, didShowItem: self.item)
            self.fromDelegate?.previewable?(self.fromContext, didShowItem: self.item)

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
}