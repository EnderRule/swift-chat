//
//  SAInputView.swift
//  SAInputBar
//
//  Created by sagesse on 7/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal class SAInputView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return _inputView?.intrinsicContentSize ?? .zero
    }
    
    func updateInputMode(_ newMode: SAInputMode, oldMode: SAInputMode, animated: Bool) {
        _logger.trace()
        
        _inputMode = newMode
        
        switch newMode {
        case .selecting(let view):
            guard view != _inputView else {
                break // no change
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            // view.backgroundColor = 
            
            addSubview(view)
            
            let viewcs = [
                _SAInputLayoutConstraintMake(view, .top, .equal, self, .top),
                _SAInputLayoutConstraintMake(view, .left, .equal, self, .left),
                _SAInputLayoutConstraintMake(view, .right, .equal, self, .right),
            ]
            
            addConstraints(viewcs)
            
            view.layoutIfNeeded()
            view.frame = CGRect(origin: .zero, size: view.frame.size)
            //setNeedsLayout()
            //layoutIfNeeded()
            
            if let oview = _inputView, let oviewcs = _inputViewConstraints, oldMode.isSelecting {
                
                oview.transform = CGAffineTransform(translationX: 0, y: 0)
                view.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                
                UIView.animate(withDuration: _SAInputDefaultAnimateDuration, animations: { 
                    UIView.setAnimationCurve(_SAInputDefaultAnimateCurve)
                    
                    oview.transform = CGAffineTransform(translationX: 0, y: oview.frame.height)
                    view.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: { b in
                    guard self._inputView !== oview  else {
                        return
                    }
                    self.removeConstraints(oviewcs)
                    oview.removeFromSuperview()
                    oview.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
            
            // update input view
            _inputView = view
            _inputViewConstraints = viewcs
            
        default:
            if let oview = _inputView, let oviewcs = _inputViewConstraints {
                UIView.animate(withDuration: _SAInputDefaultAnimateDuration, animations: { 
                    UIView.setAnimationCurve(_SAInputDefaultAnimateCurve)
                    oview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0)
                }, completion: { b in
                    if self._inputMode.isSelecting && self._inputView === oview {
                        return // ignore
                    }
                    self.removeConstraints(oviewcs)
                    oview.removeFromSuperview()
                    self._inputView = nil
                    self._inputViewConstraints = nil
                })
            }
            break
        }
        
        invalidateIntrinsicContentSize()
    }
    
    private var _inputMode: SAInputMode = .none
    private var _inputView: UIView?
    private var _inputViewConstraints: [NSLayoutConstraint]?
}

