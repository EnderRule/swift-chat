//
//  SAEmotionPage.swift
//  SIMChat
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAEmotionPage {
    
    func draw(in ctx: CGContext) {
        
        //ctx.setFillColor(UIColor.orange.withAlphaComponent(0.1).cgColor)
        //ctx.fill(bounds)
        //ctx.fill(visableRect)
        //ctx.fill(vaildRect)
        
        lines.forEach { 
            $0.draw(in: ctx)
        }
    }
    func contents(fetch: @escaping ((Any?) -> (Void))) {
        if let contents = _contents {
            fetch(contents.cgImage)
            return
        }
        SAEmotionPage.queue.async {
            
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            
            if let ctx = UIGraphicsGetCurrentContext() {
                self.draw(in: ctx)
            }
            let img = UIGraphicsGetImageFromCurrentImageContext()
            self._contents = img
            
            UIGraphicsEndImageContext()
            
            fetch(img?.cgImage)
        }
    }
    
    func addEmotion(_ emotion: SAEmotion) -> Bool {
        guard let lastLine = lines.last else {
            return false
        }
        if lastLine.addEmotion(emotion) {
            visableSize.width = max(visableSize.width, lastLine.visableSize.width)
            visableSize.height = lastLine.vaildRect.minY - vaildRect.minY + lastLine.visableSize.height
            return true
        }
        let rect = UIEdgeInsetsInsetRect(vaildRect, UIEdgeInsetsMake(visableSize.height + minimumLineSpacing, 0, 0, 0))
        let line = SAEmotionLine(emotion, itemSize, rect, minimumLineSpacing, minimumInteritemSpacing, itemType)
        if floor(line.vaildRect.minY + line.visableSize.height) > floor(vaildRect.maxY) {
            return false
        }
        lines.append(line)
        return true
    }
    
    func emotion(at indexPath: IndexPath) -> SAEmotion? {
        guard indexPath.section < lines.count else {
            return nil
        }
        let line = lines[indexPath.section]
        guard indexPath.item < line.emotions.count else {
            return nil
        }
        return line.emotions[indexPath.item]
    }
    func rect(at indexPath: IndexPath) -> CGRect? {
        guard indexPath.section < lines.count else {
            return nil
        }
        return lines[indexPath.section].rect(at: indexPath.item)
    }
    
    var bounds: CGRect
    
    var vaildRect: CGRect
    var visableSize: CGSize
    var visableRect: CGRect
    
    var itemSize: CGSize
    var itemType: SAEmotionType
    
    var minimumLineSpacing: CGFloat
    var minimumInteritemSpacing: CGFloat
    
    var lines: [SAEmotionLine]
    
    private var _contents: UIImage?
    
    init(_ first: SAEmotion,
         _ itemSize: CGSize,
         _ rect: CGRect,
         _ bounds: CGRect,
         _ lineSpacing: CGFloat,
         _ interitemSpacing: CGFloat,
         _ itemType: SAEmotionType) {
        
        let nlsp = lineSpacing / 2
        let nisp = interitemSpacing / 2
        
        let nrect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(nlsp, nisp, nlsp, nisp))
        let line = SAEmotionLine(first, itemSize, nrect, lineSpacing, interitemSpacing, itemType)
        
        self.bounds = bounds
        self.itemSize = itemSize
        self.itemType = itemType
        
        self.vaildRect = nrect
        self.visableSize = line.visableSize
        self.visableRect = rect
        
        self.minimumLineSpacing = lineSpacing
        self.minimumInteritemSpacing = interitemSpacing
        
        self.lines = [line]
    }
    
    static var queue = DispatchQueue(label: "sa.emotion.background")
}
