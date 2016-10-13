//
//  SAPhotoPreviewingView.swift
//  SIMChat
//
//  Created by sagesse on 10/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal class SAPhotoPreviewingView: UIView {
    
    var image: UIImage? {
        willSet {
            let m = rotation(newValue)
            
            //let oldImage = image
            let newImage = m.0
            
            contentView.image = newImage
            transform = CGAffineTransform(rotationAngle: m.1)
        }
    }
    var previewing: SAPhotoPreviewingContext? {
        willSet {
            image = newValue?.previewingImage ?? previewing?.previewingImage
            contentMode = newValue?.previewingContentMode ?? .scaleToFill
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = align(bounds, with: image?.size ?? .zero, with: contentMode)
    }
    
    func align(_ rect: CGRect, with size: CGSize, with contentMode: UIViewContentMode) -> CGRect {
        // if contentMode is scale is used in all rect
        if contentMode == .scaleToFill {
            return rect
        }
        var x = rect.minX
        var y = rect.minY
        var width = size.width
        var height = size.height
        // if contentMode is aspect scale to fit, calculate the zoom ratio
        if contentMode == .scaleAspectFit {
            let scale = min(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // if contentMode is aspect scale to fill, calculate the zoom ratio
        if contentMode == .scaleAspectFill {
            let scale = max(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // horizontal alignment
        if [.left, .topLeft, .bottomLeft].contains(contentMode) {
            // align left
            x += (0)
            
        } else if [.right, .topRight, .bottomRight].contains(contentMode) {
            // align right
            x += (rect.width - width)
            
        } else {
            // algin center
            x += (rect.width - width) / 2
        }
        // vertical alignment
        if [.top, .topLeft, .topRight].contains(contentMode) {
            // align top
            y += (0)
            
        } else if [.bottom, .bottomLeft, .bottomRight].contains(contentMode) {
            // align bottom
            y += (rect.height - width)
            
        } else {
            // algin center
            y += (rect.height - height) / 2
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    func rotation(_ image: UIImage?) -> (UIImage?, CGFloat) {
        guard let img = image?.cgImage, let orientation = image?.imageOrientation else {
            return (image, 0)
        }
        var newImage: UIImage {
            return UIImage(cgImage: img, scale: image?.scale ?? 1, orientation: .up)
        }
        
        switch orientation {
        case .up,
             .upMirrored:
            return (image, 0 * CGFloat(M_PI_2))
            
        case .right,
             .rightMirrored:
            return (newImage, 1 * CGFloat(M_PI_2))
            
        case .down,
             .downMirrored:
            return (newImage, 2 * CGFloat(M_PI_2))
            
        case .left,
             .leftMirrored:
            return (newImage, 3 * CGFloat(M_PI_2))
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        contentView.contentMode = .scaleAspectFill
        
        addSubview(contentView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not support")
    }
    
    private lazy var contentView: UIImageView = UIImageView()
}
