//
//  SIMChatLabel.swift
//  SIMChat <https://github.com/sagesse-cn/swift-chat>
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by sagesse on 4/5/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import SIMChat

import UIKit
import CoreText
import CoreFoundation

public let SIMChatTextAttachmentAttributeName = "SIMChatTextAttachment"

public let SIMChatTextAttachmentToken = "\u{fffc}"
public let SIMChatTextTruncationToken = "\u{2026}"

private func _SIMChatTextDebug(path: CGPath?, _ size: CGSize) {
    let context = UIGraphicsGetCurrentContext()
    
    CGContextSaveGState(context)
    
//    CGContextTranslateCTM(context, 0, size.height)
    CGContextScaleCTM(context, 1.0, -1.0)
    
    // set attrib
    UIColor.redColor().setStroke()
    CGContextSetLineWidth(context, 2)
    // draw
    CGContextAddPath(context, path)
    CGContextStrokePath(context)
    
    CGContextRestoreGState(context)
    
}

private func _SIMChatTextDraw(frame: CTFrame, _ size: CGSize) {
    let context = UIGraphicsGetCurrentContext()
    
    CGContextSaveGState(context)
    
    UIColor.purpleColor().setStroke()
    
//    CGContextTranslateCTM(context, 0, size.height)
    CGContextScaleCTM(context, 1.0, -1.0)
    
    CTFrameDraw(frame, context!)
    
    CGContextRestoreGState(context)
}
//private func _SIMChatTextDraw(line: CTLine, _ size: CGSize) {
//    let context = UIGraphicsGetCurrentContext()
//    
//    CGContextSaveGState(context)
//    
//    UIColor.purpleColor().setStroke()
//    
////    CGContextTranslateCTM(context, 0, size.height)
//    CGContextScaleCTM(context, 1.0, -1.0)
//    
//    CTLineDraw(line, context!)
//    
//    CGContextRestoreGState(context)
//}

private func _SIMChatTextDebug(rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    
    CGContextSaveGState(context)
    
//    CGContextTranslateCTM(context, 0, size.height)
//    CGContextScaleCTM(context, 1.0, -1.0)
    
    // set attrib
    UIColor.redColor().setStroke()
    CGContextSetLineWidth(context, 1)
    // draw
    CGContextAddRect(context, rect)
//    CGContextAddPath(context, path)
    CGContextStrokePath(context)
    
    CGContextRestoreGState(context)
    
}

private func _SIMChatTextAttachmentRelease(ref: UnsafeMutablePointer<Void>) {
    let _: AnyObject = Unmanaged.fromOpaque(COpaquePointer(ref)).takeRetainedValue()
}
private func _SIMChatTextAttachmentRetain(obj: AnyObject) -> UnsafeMutablePointer<Void> {
    return UnsafeMutablePointer<Void>(Unmanaged.passRetained(obj).toOpaque())
}

private func _SIMChatTextAttachmentGetWidth(ref: UnsafeMutablePointer<Void>) -> CGFloat {
    return Unmanaged<SIMChatTextAttachment>.fromOpaque(COpaquePointer(ref)).takeUnretainedValue().width
}
private func _SIMChatTextAttachmentGetAscent(ref: UnsafeMutablePointer<Void>) -> CGFloat {
    return Unmanaged<SIMChatTextAttachment>.fromOpaque(COpaquePointer(ref)).takeUnretainedValue().ascent
}
private func _SIMChatTextAttachmentGetDescent(ref: UnsafeMutablePointer<Void>) -> CGFloat {
    return Unmanaged<SIMChatTextAttachment>.fromOpaque(COpaquePointer(ref)).takeUnretainedValue().descent
}

private func _SIMChatTextDraw(line: SIMChatTextLine, context: CGContext?, size: CGSize) {
    (CTLineGetGlyphRuns(line.line) as NSArray).forEach {
        let run = $0 as! CTRun
        let attrs = CTRunGetAttributes(run) as NSDictionary
        let textMatrix = CTRunGetTextMatrix(run)
        let textMatrixIsId = CGAffineTransformIsIdentity(textMatrix)
        
        if !textMatrixIsId {
            CGContextSaveGState(context)
            CGContextSetTextMatrix(context, CGAffineTransformConcat(CGContextGetTextMatrix(context), textMatrix))
        }
        
        CTRunDraw(run, context!, CFRangeMake(0, 0))
        
        if !textMatrixIsId {
            CGContextRestoreGState(context)
        }
    }
}

//static void YYTextDrawRun(YYTextLine *line, CTRunRef run, CGContextRef context, CGSize size, BOOL isVertical, NSArray *runRanges, CGFloat verticalOffset) {
//    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
//    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
//    
//    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
//    NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(YYTextGlyphTransformAttributeName));
//    if (!isVertical && !glyphTransformValue) { // draw run
//        if (!runTextMatrixIsID) {
//            CGContextSaveGState(context);
//            CGAffineTransform trans = CGContextGetTextMatrix(context);
//            CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
//        }
//        CTRunDraw(run, context, CFRangeMake(0, 0));
//        if (!runTextMatrixIsID) {
//            CGContextRestoreGState(context);
//        }
//    } else { // draw glyph
//        CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
//        if (!runFont) return;
//        NSUInteger glyphCount = CTRunGetGlyphCount(run);
//        if (glyphCount <= 0) return;
//        
//        CGGlyph glyphs[glyphCount];
//        CGPoint glyphPositions[glyphCount];
//        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
//        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
//        
//        CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
//        if (!fillColor) fillColor = [UIColor blackColor].CGColor;
//        NSNumber *strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
//        
//        CGContextSaveGState(context); {
//            CGContextSetFillColorWithColor(context, fillColor);
//            if (!strokeWidth || strokeWidth.floatValue == 0) {
//                CGContextSetTextDrawingMode(context, kCGTextFill);
//            } else {
//                CGColorRef strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
//                if (!strokeColor) strokeColor = fillColor;
//                CGContextSetStrokeColorWithColor(context, strokeColor);
//                CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
//                if (strokeWidth.floatValue > 0) {
//                    CGContextSetTextDrawingMode(context, kCGTextStroke);
//                } else {
//                    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
//                }
//            }
//            
//            if (isVertical) {
//                CFIndex runStrIdx[glyphCount + 1];
//                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                CFRange runStrRange = CTRunGetStringRange(run);
//                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                CGSize glyphAdvances[glyphCount];
//                CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                CGFloat ascent = CTFontGetAscent(runFont);
//                CGFloat descent = CTFontGetDescent(runFont);
//                CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                CGPoint zeroPoint = CGPointZero;
//                
//                for (YYTextRunGlyphRange *oneRange in runRanges) {
//                    NSRange range = oneRange.glyphRangeInRun;
//                    NSUInteger rangeMax = range.location + range.length;
//                    YYTextRunGlyphDrawMode mode = oneRange.drawMode;
//                    
//                    for (NSUInteger g = range.location; g < rangeMax; g++) {
//                        CGContextSaveGState(context); {
//                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                            if (glyphTransformValue) {
//                                CGContextSetTextMatrix(context, glyphTransform);
//                            }
//                            if (mode) { // CJK glyph, need rotated
//                                CGFloat ofs = (ascent - descent) * 0.5;
//                                CGFloat w = glyphAdvances[g].width * 0.5;
//                                CGFloat x = x = line.position.x + verticalOffset + glyphPositions[g].y + (ofs - w);
//                                CGFloat y = -line.position.y + size.height - glyphPositions[g].x - (ofs + w);
//                                if (mode == YYTextRunGlyphDrawModeVerticalRotateMove) {
//                                    x += w;
//                                    y += w;
//                                }
//                                CGContextSetTextPosition(context, x, y);
//                            } else {
//                                CGContextRotateCTM(context, DegreesToRadians(-90));
//                                CGContextSetTextPosition(context,
//                                                         line.position.y - size.height + glyphPositions[g].x,
//                                                         line.position.x + verticalOffset + glyphPositions[g].y);
//                            }
//                            
//                            if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                            } else {
//                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                CGContextSetFont(context, cgFont);
//                                CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                CGFontRelease(cgFont);
//                            }
//                        } CGContextRestoreGState(context);
//                    }
//                }
//            } else { // not vertical
//                if (glyphTransformValue) {
//                    CFIndex runStrIdx[glyphCount + 1];
//                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
//                    CFRange runStrRange = CTRunGetStringRange(run);
//                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
//                    CGSize glyphAdvances[glyphCount];
//                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
//                    CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
//                    CGPoint zeroPoint = CGPointZero;
//                    
//                    for (NSUInteger g = 0; g < glyphCount; g++) {
//                        CGContextSaveGState(context); {
//                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//                            CGContextSetTextMatrix(context, glyphTransform);
//                            CGContextSetTextPosition(context,
//                                                     line.position.x + glyphPositions[g].x,
//                                                     size.height - (line.position.y + glyphPositions[g].y));
//                            
//                            if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
//                            } else {
//                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                                CGContextSetFont(context, cgFont);
//                                CGContextSetFontSize(context, CTFontGetSize(runFont));
//                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
//                                CGFontRelease(cgFont);
//                            }
//                        } CGContextRestoreGState(context);
//                    }
//                } else {
//                    if (CTFontContainsColorBitmapGlyphs(runFont)) {
//                        CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
//                    } else {
//                        CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
//                        CGContextSetFont(context, cgFont);
//                        CGContextSetFontSize(context, CTFontGetSize(runFont));
//                        CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
//                        CGFontRelease(cgFont);
//                    }
//                }
//            }
//            
//        } CGContextRestoreGState(context);
//    }
//}

private func _SIMChatTextDraw(layout: SIMChatTextLayout, context: CGContextRef?, rect: CGRect) {
    CGContextSaveGState(context)
    
    CGContextTranslateCTM(context, rect.minX, rect.maxY)
    CGContextScaleCTM(context, 1, -1)
    CGContextSetShadow(context, CGSizeZero, 0)
    
    for line in layout.lines {
        
//            NSArray *lineRunRanges = line.verticalRotateRange;
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextSetTextPosition(context, line.position.x, rect.height - line.position.y)
        
//        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
//        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
//            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
//            YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
//        }
        
        _SIMChatTextDraw(line, context: context, size: rect.size)
    }
    
//        BOOL isVertical = layout.container.verticalForm;
//        CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
//        
//        NSArray *lines = layout.lines;
//        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
//            YYTextLine *line = lines[l];
//            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
//            NSArray *lineRunRanges = line.verticalRotateRange;
//            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//            CGContextSetTextPosition(context, line.position.x + verticalOffset, size.height - line.position.y);
//            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
//            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
//                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
//                YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
//            }
//            if (cancel && cancel()) break;
//        }
    
    // Use this to draw frame for test/debug.
    // CGContextTranslateCTM(context, 0, rect.height)
    // CTFrameDraw(layout._frame!, context!)
    
    CGContextRestoreGState(context)
}
//static void YYTextDrawText(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
//    CGContextSaveGState(context); {
//        
//        CGContextTranslateCTM(context, point.x, point.y);
//        CGContextTranslateCTM(context, 0, size.height);
//        CGContextScaleCTM(context, 1, -1);
//        CGContextSetShadow(context, CGSizeZero, 0);
//        
//        BOOL isVertical = layout.container.verticalForm;
//        CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
//        
//        NSArray *lines = layout.lines;
//        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
//            YYTextLine *line = lines[l];
//            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
//            NSArray *lineRunRanges = line.verticalRotateRange;
//            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//            CGContextSetTextPosition(context, line.position.x + verticalOffset, size.height - line.position.y);
//            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
//            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
//                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
//                YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
//            }
//            if (cancel && cancel()) break;
//        }
//        
//        // Use this to draw frame for test/debug.
//        // CGContextTranslateCTM(context, verticalOffset, size.height);
//        // CTFrameDraw(layout.frame, context);
//        
//    } CGContextRestoreGState(context);
//}


///
/// The SIMChatTextContainer class defines a region in which text is laid out.
/// SIMChatTextLayout class uses one or more SIMChatTextContainer objects to generate layouts.
/// 
/// A SIMChatTextContainer defines rectangular regions (`size` and `insets`) or
/// nonrectangular shapes (`path`), and you can define exclusion paths inside the
/// text container's bounding rectangle so that text flows around the exclusion
/// path as it is laid out.
/// 
/// Example:
/// 
///     ┌─────────────────────────────┐  <------- container
///     │                             │
///     │    asdfasdfasdfasdfasdfa   <------------ container insets
///     │    asdfasdfa   asdfasdfa    │
///     │    asdfas         asdasd    │
///     │    asdfa        <----------------------- container exclusion path
///     │    asdfas         adfasd    │
///     │    asdfasdfa   asdfasdfa    │
///     │    asdfasdfasdfasdfasdfa    │
///     │                             │
///     └─────────────────────────────┘
///
public class SIMChatTextContainer {
    
    ///
    /// Creates a container with the specified path.
    ///
    /// - parameter path: The path.
    ///
    public init(path: UIBezierPath) {
        self.path = path
    }
    
    ///
    /// Creates a container with the specified size.
    ///
    /// - parameter size: The size.
    /// - parameter insets: The insets.
    ///
    public init(size: CGSize, insets: UIEdgeInsets = UIEdgeInsetsZero) {
        self.size = size
        self.insets = insets
    }
    
    /// The constrained size. (if the size is larger than CGRectMake(CGFloat.max, CGFloat.max), it will be clipped)
    public lazy var size: CGSize = CGSizeMake(CGFloat.max, CGFloat.max)
    
    /// The insets for constrained size. The inset value should not be negative. Default is UIEdgeInsetsZero.
    public lazy var insets: UIEdgeInsets = UIEdgeInsetsZero
    
    /// Default value: NSLineBreakByWordWrapping  The line break mode defines the behavior of the last line inside the text container.
    public lazy var lineBreakMode: NSLineBreakMode = .ByWordWrapping
    
    /// Maximum number of rows, 0 means no limit. Default is 0.
    public lazy var maximumNumberOfLines: Int = 0
    
    /// An array of `UIBezierPath` for path exclusion. Default is nil.
    public lazy var exclusionPaths: [UIBezierPath] = []
    
    /// Custom constrained path. Set this property to ignore `size` and `insets`. Default is nil.
    @NSCopying public var path: UIBezierPath?
    
    /// The truncation token. If nil, the layout will use "…" instead. Default is nil.
    @NSCopying public var truncationToken: NSAttributedString?
}

///
/// SIMChatTextLayout class is a readonly class stores text layout result.
/// All the property in this class is readonly, and should not be changed.
/// The methods in this class is thread-safe (except some of the draw methods).
/// 
/// example: (layout with a circle exclusion path)
/// 
///     ┌──────────────────────────┐  <------ container
///     │ [--------Line0--------]  │  <- Row0
///     │ [--------Line1--------]  │  <- Row1
///     │ [-Line2-]     [-Line3-]  │  <- Row2
///     │ [-Line4]       [Line5-]  │  <- Row3
///     │ [-Line6-]     [-Line7-]  │  <- Row4
///     │ [--------Line8--------]  │  <- Row5
///     │ [--------Line9--------]  │  <- Row6
///     └──────────────────────────┘
///
public class SIMChatTextLayout {
    
    /// The full text
    @NSCopying public var text: NSAttributedString
    
    /// The text range in full text
    public var range: NSRange
    
    /// The text contaner
    public var container: SIMChatTextContainer
    
    private var _frame: CTFrame?
    private var _frameSetter: CTFramesetter?
    
    public lazy var lines: Array<SIMChatTextLine> = []
    
    ///
    /// Creates a layout with the container.
    ///
    /// - parameter text: The text.
    /// - parameter container: The container.
    /// - parameter range: The range.
    ///
    private init(text: NSAttributedString, container: SIMChatTextContainer, range: NSRange) {
        self.text = text
        self.range = range
        self.container = container
    }
    
    ///
    /// Generate a layout with the given container size and text.
    ///
    /// - parameter text: The text
    /// - parameter size: The text container's size
    ///
    /// - returns A new layout
    ///
    public static func layout(text: NSAttributedString, size: CGSize) -> SIMChatTextLayout {
        return layout(text, container: SIMChatTextContainer(size: size))
    }
    
    ///
    /// Generate a layout with the given container and text.
    ///
    /// - parameter container: The text container
    /// - parameter text:      The text
    /// - parameter range:     The text range. If the length of the range is 0, it means the length is no limit.
    ///
    /// - returns: A new layout
    ///
    static func layout(text: NSAttributedString, container: SIMChatTextContainer, range: NSRange? = nil) -> SIMChatTextLayout {
        let range = range ?? NSMakeRange(0, text.length)
        let maximumNumberOfLines = container.maximumNumberOfLines
        
        let layout = SIMChatTextLayout(text: text, container: container, range: range)
        
        // fetch or generate the default path
        var path = container.path?.CGPath ?? {
            let rect = CGRect(origin: CGPointZero, size: container.size)
            let box = UIEdgeInsetsInsetRect(rect, container.insets)
            return CGPathCreateWithRect(box, nil)
        }()
        // add the exclusion path, if need
        if !container.exclusionPaths.isEmpty {
            path = container.exclusionPaths.reduce(CGPathCreateMutableCopy(path)) {
                CGPathAddPath($0, nil, $1.CGPath)
                return $0
            } ?? path
        }
        // get path box bounds
        let pathBox = CGPathGetPathBoundingBox(path)
        // reverse y
        path = {
            var trans = CGAffineTransformMakeScale(1, -1)
            return CGPathCreateMutableCopyByTransformingPath(path, &trans)
        }() ?? path
        
        // frame setter config
        let frameAttrs = NSMutableDictionary()
        
        // create coretext objcts
        let frameSetter = CTFramesetterCreateWithAttributedString(text)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(range.location, range.length), path, frameAttrs)
       
        var row = 0
        var last = (position: CGPoint, rect: CGRect)?()
        var needTruncation = false
        var textBoundingRect = CGRectZero
        
        // calculate line frame
        var lines: [SIMChatTextLine] = (CTFrameGetLines(frame) as NSArray).enumerate().flatMap { (i, e) in
            let position: CGPoint = {
                var origin = CGPointZero
                // read origin form frame
                CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origin)
                // convert CoreText coordinate to UIKit coordinate
                return CGPointMake(pathBox.minX + origin.x, pathBox.maxY - origin.y)
            }()
            let line = SIMChatTextLine(line: e as! CTLine, position: position)
            let rect = line.frame
            
            // check the line is a new row
            if let last = last {
                let pt = CGPointMake(
                    last.rect.minX,
                    position.y
                )
                let lpt = CGPointMake(
                    rect.minX,
                    last.position.y
                )
                if !(last.rect.contains(pt) || rect.contains(lpt)) {
                    row += 1
                }
            }
            
            _SIMChatTextDebug(rect)
            //_SIMChatTextDraw(line.line, container.size)
            
            // maximumNumberOfLines conditions must be met
            guard maximumNumberOfLines == 0 || row < maximumNumberOfLines else {
                needTruncation = true
                return nil
            }
            
            last = (position, rect)
            textBoundingRect = i != 0 ? CGRectUnion(textBoundingRect, rect) : rect
            
            // update line info
            line.row = row
            
            SIMLog.debug("\(i) => \(row) => \(line.range)")
            
            return line
        }
        
        // check last line
        if let last = lines.last {
            if !needTruncation && last.range.location + last.range.length < text.length {
                needTruncation = true
            }
        }
        
        // calculate bounding size
        let textBoundingSize: CGSize = {
            var rect = textBoundingRect
            if container.path == nil {
                let edg = UIEdgeInsetsMake(-container.insets.top,
                                           -container.insets.left,
                                           -container.insets.bottom,
                                           -container.insets.right)
                rect = UIEdgeInsetsInsetRect(rect, edg)
            } else {
                // ..
            }
            
            let width = rect.maxX
            let height = rect.maxY
            
            return CGSizeMake(max(ceil(width), 0), max(ceil(height), 0))
        }()
        
        // calculate visibleRange
        var visibleRange: NSRange = {
            let range = CTFrameGetVisibleStringRange(frame)
            return NSMakeRange(range.location, range.length)
        }()
        
        // truncation text, if need
        if let last = lines.last where needTruncation {
            // adj lenght
            visibleRange.length = last.range.location + last.range.length - visibleRange.location
            // create truncated line
            
            let truncationToken = container.truncationToken ?? {
                var attrs: [String: AnyObject]?
                if let run = (CTLineGetGlyphRuns(last.line) as NSArray).lastObject as! CTRun? {
                    var dic = (CTRunGetAttributes(run) as NSDictionary) as? [String: AnyObject]
                    
                    // clean
                    dic?.removeValueForKey(SIMChatTextAttachmentAttributeName)
                    dic?[String(kCTFontAttributeName)] = {
                        var fontSize = CGFloat(12)
                        if let font = dic?[String(kCTFontAttributeName)] as! CTFont? {
                            fontSize = CTFontGetSize(font)
                        }
                        return UIFont.systemFontOfSize(fontSize * 0.9)
                    }() as CTFont
                    
                    attrs = dic
                }
                return NSAttributedString(string: SIMChatTextTruncationToken, attributes: attrs)
            }()
            let truncationTokenLine = CTLineCreateWithAttributedString(truncationToken)
           
            let lastLineText = text.attributedSubstringFromRange(last.range).mutableCopy() as! NSMutableAttributedString
            lastLineText.appendAttributedString(truncationToken)
            let ctLastLineExtend = CTLineCreateWithAttributedString(lastLineText)
            
//
            //last.bounds.width
            
            
//            var tw = last.lineWidth
//            tw = pathBox.width
//                                CGFloat truncatedWidth = lastLine.width;
//                                CGRect cgPathRect = CGRectZero;
//                                if (CGPathIsRect(cgPath, &cgPathRect)) {
//                                    if (isVerticalForm) {
//                                        truncatedWidth = cgPathRect.size.height;
//                                    } else {
//                                        truncatedWidth = cgPathRect.size.width;
//                                    }
//                                }
            
            //    kCTLineTruncationStart  = 0
            //    kCTLineTruncationEnd    = 1
            //    kCTLineTruncationMiddle = 2
            //CTLineTruncationType.End
            //let line = CTLineCreateTruncatedLine(ctLastLineExtend, Double(last.lineWidth), .End, truncationTokenLine)
            //let line = CTLineCreateTruncatedLine(ctLastLineExtend, Double(last.bounds.width), .Middle, truncationTokenLine)
            let line = CTLineCreateTruncatedLine(ctLastLineExtend, Double(last.bounds.width), .Start, truncationTokenLine)
            
            
            let t = SIMChatTextLine(line: line!, position: last.position)
            
            t.row = last.row
            
            lines.removeLast()
            lines.append(t)
            
            //                        truncatedLine = [YYTextLine lineWithCTLine:ctTruncatedLine position:lastLine.position vertical:isVerticalForm];
            //                        truncatedLine.index = lastLine.index;
            //                        truncatedLine.row = lastLine.row;
           
            //            if (truncationTokenLine) {
            //                CTLineTruncationType type = kCTLineTruncationEnd;
            //                if (container.truncationType == YYTextTruncationTypeStart) {
            //                    type = kCTLineTruncationStart;
            //                } else if (container.truncationType == YYTextTruncationTypeMiddle) {
            //                    type = kCTLineTruncationMiddle;
            //                }
            //                NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
            //                [lastLineText appendAttributedString:truncationToken];
            //                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
            //                if (ctLastLineExtend) {
            //                    CGFloat truncatedWidth = lastLine.width;
            //                    CGRect cgPathRect = CGRectZero;
            //                    if (CGPathIsRect(cgPath, &cgPathRect)) {
            //                        if (isVerticalForm) {
            //                            truncatedWidth = cgPathRect.size.height;
            //                        } else {
            //                            truncatedWidth = cgPathRect.size.width;
            //                        }
            //                    }
            //                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
            //                    CFRelease(ctLastLineExtend);
            //                    if (ctTruncatedLine) {
            //                        truncatedLine = [YYTextLine lineWithCTLine:ctTruncatedLine position:lastLine.position vertical:isVerticalForm];
            //                        truncatedLine.index = lastLine.index;
            //                        truncatedLine.row = lastLine.row;
            //                        CFRelease(ctTruncatedLine);
            //                    }
            //                }
            
            //if container.lineBreakMode =
            
//    NSLineBreakByWordWrapping = 0,     	// Wrap at word boundaries, default
//    NSLineBreakByCharWrapping,		// Wrap at character boundaries
//    NSLineBreakByClipping,		// Simply clip
//    NSLineBreakByTruncatingHead,	// Truncate at head of line: "...wxyz"
//    NSLineBreakByTruncatingTail,	// Truncate at tail of line: "abcd..."
//    NSLineBreakByTruncatingMiddle	// Truncate middle of line:  "ab...yz"
            
        }
        
//    if (needTruncation) {
//        YYTextLine *lastLine = lines.lastObject;
//        NSRange lastRange = lastLine.range;
//        visibleRange.length = lastRange.location + lastRange.length - visibleRange.location;
//        
//        // create truncated line
//        if (container.truncationType != YYTextTruncationTypeNone) {
//            CTLineRef truncationTokenLine = NULL;
//            if (container.truncationToken) {
//                truncationToken = container.truncationToken;
//                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
//            } else {
//                CFArrayRef runs = CTLineGetGlyphRuns(lastLine.CTLine);
//                NSUInteger runCount = CFArrayGetCount(runs);
//                NSMutableDictionary *attrs = nil;
//                if (runCount > 0) {
//                    CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
//                    attrs = (id)CTRunGetAttributes(run);
//                    attrs = attrs.mutableCopy;
//                    [attrs removeObjectForKey:YYTextAttachmentAttributeName];
//                    CTFontRef font = (__bridge CFTypeRef)attrs[(id)kCTFontAttributeName];
//                    CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
//                    UIFont *uiFont = [UIFont systemFontOfSize:fontSize * 0.9];
//                    font = [uiFont CTFontRef];
//                    if (font) {
//                        attrs[(id)kCTFontAttributeName] = (__bridge id)(font);
//                        uiFont = nil;
//                        CFRelease(font);
//                    }
//                    if (!attrs) attrs = [NSMutableDictionary new];
//                }
//                truncationToken = [[NSAttributedString alloc] initWithString:YYTextTruncationToken attributes:attrs];
//                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
//            }
//            if (truncationTokenLine) {
//                CTLineTruncationType type = kCTLineTruncationEnd;
//                if (container.truncationType == YYTextTruncationTypeStart) {
//                    type = kCTLineTruncationStart;
//                } else if (container.truncationType == YYTextTruncationTypeMiddle) {
//                    type = kCTLineTruncationMiddle;
//                }
//                NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
//                [lastLineText appendAttributedString:truncationToken];
//                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
//                if (ctLastLineExtend) {
//                    CGFloat truncatedWidth = lastLine.width;
//                    CGRect cgPathRect = CGRectZero;
//                    if (CGPathIsRect(cgPath, &cgPathRect)) {
//                        if (isVerticalForm) {
//                            truncatedWidth = cgPathRect.size.height;
//                        } else {
//                            truncatedWidth = cgPathRect.size.width;
//                        }
//                    }
//                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
//                    CFRelease(ctLastLineExtend);
//                    if (ctTruncatedLine) {
//                        truncatedLine = [YYTextLine lineWithCTLine:ctTruncatedLine position:lastLine.position vertical:isVerticalForm];
//                        truncatedLine.index = lastLine.index;
//                        truncatedLine.row = lastLine.row;
//                        CFRelease(ctTruncatedLine);
//                    }
//                }
//                CFRelease(truncationTokenLine);
//            }
//        }
//    }
        
//    {
//        CGRect rect = textBoundingRect;
//        if (container.path) {
//            if (container.pathLineWidth > 0) {
//                CGFloat inset = container.pathLineWidth / 2;
//                rect = CGRectInset(rect, -inset, -inset);
//            }
//        } else {
//            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsInvert(container.insets));
//        }
//        rect = CGRectStandardize(rect);
//        CGSize size = rect.size;
//        if (container.verticalForm) {
//            size.width += container.size.width - (rect.origin.x + rect.size.width);
//        } else {
//            size.width += rect.origin.x;
//        }
//        size.height += rect.origin.y;
//        if (size.width < 0) size.width = 0;
//        if (size.height < 0) size.height = 0;
//        size.width = ceil(size.width);
//        size.height = ceil(size.height);
//        textBoundingSize = size;
//    }
        
        layout._frame = frame
        layout._frameSetter = frameSetter
        layout.lines = lines
        
        SIMLog.debug(textBoundingRect)
        SIMLog.debug(textBoundingSize)

//        _SIMChatTextDebug(path, container.size)
//        _SIMChatTextDebug(textBoundingRect)
//        _SIMChatTextDraw(frame, container.size)
        
        return layout
    }
    
    ///
    /// Generate layouts with the given containers and text.
    /// 
    /// - parameter containers: An array of SIMChatTextContainer object.
    /// - parameter text:       The text.
    /// - parameter range:      The text range. If the length of the range is 0, it means the length is no limit.
    ///
    /// - returns An array of SIMChatTextLayout object (the count is same as containers)
    ///
    static func layout(text: NSAttributedString, containers: [SIMChatTextContainer], range: NSRange? = nil) -> [SIMChatTextLayout] {
        var range = range ?? NSMakeRange(0, text.length)
        return containers.flatMap {
            let layout = self.layout(text, container: $0, range: range)
            range = NSMakeRange(0, 0)
            return layout
        }
    }
}

///
/// A text line object wrapped `CTLine`, see `SIMChatTextLayout` for more.
///
public class SIMChatTextLine {
    
    public init(line: CTLine, position: CGPoint = CGPointZero) {
        
        let firstOffset: CGPoint = {
            guard let run = (CTLineGetGlyphRuns(line) as NSArray).firstObject as! CTRun? else {
                return CGPointZero
            }
            var pos = CGPointZero
            CTRunGetPositions(run, CFRangeMake(0, 1), &pos)
            return pos
        }()
        // generate other
        (self.lineWidth, self.trailingWhitespaceWidth, self.ascent, self.descent, self.leading) = {
            var ascent = CGFloat(0)
            var descent = CGFloat(0)
            var leading = CGFloat(0)
            let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            let twWidth = CTLineGetTrailingWhitespaceWidth(line)
            return (CGFloat(width), CGFloat(twWidth), ascent, descent, leading)
        }()
        // generate the bounds
        self.bounds = CGRectMake(0, 0 - ascent + firstOffset.x, lineWidth, ascent + descent + leading)
        
        self.line = line
        self.position = position
        self.range = {
            let range = CTLineGetStringRange(line)
            return NSMakeRange(range.location, range.length)
        }()
        // generate the attachments
        self.attachments = (CTLineGetGlyphRuns(line) as NSArray).flatMap { e in
            let run = e as! CTRun
            let attrs = CTRunGetAttributes(run) as NSDictionary
            
            guard let attachment = attrs[SIMChatTextAttachmentAttributeName] as? SIMChatTextAttachment else {
                return nil
            }
            
            let range: CFRange = CTRunGetStringRange(run)
            let rect: CGRect = {
                var position = CGPointZero
                // get the run origin position
                CTRunGetPositions(run, CFRangeMake(0, 1), &position)
                
                var ascent = CGFloat(0)
                var descent = CGFloat(0)
                var leading = CGFloat(0)
                // get the run parameters
                let width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading))
                
                return CGRectMake(position.x , -position.y - ascent, width, ascent + descent + leading)
            }()
            
            return (attachment, NSMakeRange(range.location, range.length), rect)
        }
    }
    
    public var row: Int = 0
    
    public var frame: CGRect {
        return CGRectMake(position.x + bounds.minX, position.y + bounds.minY, bounds.width, bounds.height)
    }
    
    public let range: NSRange
    public var bounds: CGRect
    public var position: CGPoint
    
    public let line: CTLine
    public let lineWidth: CGFloat
    public let attachments: Array<(SIMChatTextAttachment, NSRange, CGRect)>
    
    public let ascent: CGFloat
    public let descent: CGFloat
    public let leading: CGFloat
    public let trailingWhitespaceWidth: CGFloat
}

///
/// ![](/Users/sagesse/Projects/swift-chat/Design/Reference/Glyphs_Metris_0.png)
/// ![](/Users/sagesse/Projects/swift-chat/Design/Reference/Glyphs_Metris_1.gif)
///
public class SIMChatTextAttachment {
    ///
    /// Additional information about the the run delegate.
    ///
    public var userInfo: Dictionary<String, AnyObject> {
        set { return _userInfo = newValue }
        get { return _userInfo }
    }
    ///
    /// The typographic width of glyphs in the run.
    ///
    public var width: CGFloat {
        set { return _width = newValue }
        get { return _width }
    }
    ///
    /// The typographic ascent of glyphs in the run.
    ///
    public var ascent: CGFloat {
        set { return _ascent = newValue }
        get { return _ascent }
    }
    ///
    /// The typographic descent of glyphs in the run.
    ///
    public var descent: CGFloat {
        set { return _descent = newValue }
        get { return _descent }
    }
    ///
    /// Creates and returns the CTRunDelegate.
    /// 
    /// The CTRunDelegateRef has a strong reference to this `SIMChatTextAttachment` object.
    /// In CoreText, use CTRunDelegateGetRefCon() to get this `SIMChatTextAttachment` object.
    /// 
    /// - returns: The `CTRunDelegate` object.
    ///
    public var runDelegate: CTRunDelegate {
        get { return _runDelegate }
    }
    
    private lazy var _width: CGFloat = 0.0
    private lazy var _ascent: CGFloat = 0.0
    private lazy var _descent: CGFloat = 0.0
    private lazy var _userInfo: Dictionary<String, AnyObject> = [:]
    
    private lazy var _runDelegate: CTRunDelegate = {
        var callbacks = CTRunDelegateCallbacks(
            version: kCTRunDelegateCurrentVersion,
            dealloc: _SIMChatTextAttachmentRelease,
            getAscent: _SIMChatTextAttachmentGetAscent,
            getDescent: _SIMChatTextAttachmentGetDescent,
            getWidth: _SIMChatTextAttachmentGetWidth)
        return CTRunDelegateCreate(&callbacks, _SIMChatTextAttachmentRetain(self))!
    }()
}


public class SIMChatLabel: UIView {

    public override func drawRect(rect: CGRect) {
        // Drawing code
        
        let path = CGPathCreateMutable()
        
        
        CGPathAddRect(path, nil, CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        
        let ms = NSMutableAttributedString(string: "abcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabc")
//        let ms = NSMutableAttributedString(string: "abcabcabcabcabcabcabcabcabc")
        var attributes: [String: AnyObject] = [:]
        
        attributes[String(kCTForegroundColorAttributeName)] = UIColor.purpleColor().CGColor
        attributes[String(kCTFontAttributeName)] = CTFontCreateWithName(UIFont.italicSystemFontOfSize(20).fontName, 20, nil)
        //attributes[String(kCTUnderlineStyleAttributeName)] = 9//kCTUnderlineStyleDouble
        //kCTUnderlineStyleAttributeName
        
//        //换行模式
//        CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
//        CTParagraphStyleSetting lineBreakMode;
//        lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
//        lineBreakMode.value = &lineBreak;
//        lineBreakMode.valueSize = sizeof(CTLineBreakMode);
        
        ms.addAttributes(attributes, range: NSMakeRange(0, ms.length))
        
        var kk = NSMakeRange(0, ms.length)
        print(ms.attributesAtIndex(0, effectiveRange: &kk))
        
//        let att = SIMChatTextAttachment()
//        
//        att.width = 88
//        att.ascent = 32
//        att.descent = 0
//        
//        ms.addAttribute(
//            String(kCTRunDelegateAttributeName),
//            value: att.runDelegate,
//            range: NSMakeRange(0, 1))
        
        
        //let c1 = SIMChatTextContainer(path: UIBezierPath(roundedRect: bounds, cornerRadius: 20))
//        let c1 = SIMChatTextContainer(path: UIBezierPath(roundedRect: CGRectMake(0, 0, 320, 320), cornerRadius: 20))
        let c1 = SIMChatTextContainer(size: CGSize(width: 320, height: 320), insets: UIEdgeInsetsMake(10, 10, 10, 10))
        c1.exclusionPaths = [
            UIBezierPath(ovalInRect: CGRectMake((320 - 120) / 2 - 50, (320 - 120) / 2 - 50, 120, 120)),
            UIBezierPath(ovalInRect: CGRectMake((320 - 120) / 2 + 50, (320 - 120) / 2 + 50, 120, 120)),
            UIBezierPath(ovalInRect: CGRectMake((320 - 120) / 2, (320 - 120) / 2, 120, 120))
        ]
        
        //c1.maximumNumberOfLines = 2
        
        let layout = SIMChatTextLayout.layout(ms, container: c1)
        
        _SIMChatTextDraw(layout, context: UIGraphicsGetCurrentContext(), rect: CGRectMake(0, 0, 320, 320))
        //SIMChatLayoutRunDelegate
        //let zzz = TTT()
        
//        //CTRunDelegateCreate
//
//        
//        let setter = CTFramesetterCreateWithAttributedString(ms)
//        let frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, nil)
//        
//        let lines = CTFrameGetLines(frame)
//        
//        print(CFArrayGetCount(lines))
//        
//        let context = UIGraphicsGetCurrentContext()
//        
//        CGContextSaveGState(context)
//        
//        CGContextTranslateCTM(context, 0 ,self.bounds.size.height)
//        CGContextScaleCTM(context, 1.0 ,-1.0)
//        
//        CTFrameDraw(frame, context!)
//    
//        CGContextRestoreGState(context)
    }
}
