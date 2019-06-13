

#import "VVTextLayout.h"

#import <objc/runtime.h>

#import "VVTextLine.h"
#import "CALayer+WebCache.h"
#import "VVCGRectTransform.h"
#import "CALayer+VVTransaction.h"
#import "VVAsyncImageView.h"
#import "YYAnimatedImageView+WebCache.h"

static inline CGSize _getSuggetSizeAndRange(CTFramesetterRef framesetter,
        NSAttributedString *attributedString,
        CGSize size,
        NSUInteger numberOfLines,
        CFRange *rangeToSize);

@interface VVTextLayout ()

@property(nonatomic, strong) VVTextContainer *container;
@property(nonatomic, strong) NSAttributedString *text;
@property(nonatomic, assign) CGRect cgPathBox;
@property(nonatomic, assign) CGPathRef cgPath;
@property(nonatomic, assign) CGPathRef suggestPathRef;
@property(nonatomic, assign) CTFrameRef ctFrame;
@property(nonatomic, assign) CTFramesetterRef ctFrameSetter;
@property(nonatomic, assign) CGSize suggestSize;
@property(nonatomic, strong) NSArray<VVTextLine *> *linesArray;
@property(nonatomic, assign) CGRect textBoundingRect;
@property(nonatomic, assign) CGSize textBoundingSize;
@property(nonatomic, strong) NSArray<VVTextAttachment *> *attachments;
@property(nonatomic, strong) NSArray<NSValue *> *attachmentRanges;
@property(nonatomic, strong) NSArray<NSValue *> *attachmentRects;
@property(nonatomic, strong) NSSet<id> *attachmentContentsSet;
@property(nonatomic, strong) NSArray<VVTextHighlight *> *textHighlights;
@property(nonatomic, strong) NSArray<VVTextBackgroundColor *> *backgroundColors;
@property(nonatomic, strong) NSArray<VVTextBoundingStroke *> *boudingStrokes;
@property(nonatomic, assign) NSInteger numberOfLines;
@property(nonatomic, assign) BOOL needTruncation;

@end


@implementation VVTextLayout

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.container forKey:@"container"];
    [aCoder encodeObject:self.text forKey:@"text"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    VVTextContainer *container = [aDecoder decodeObjectForKey:@"container"];
    NSAttributedString *text = [aDecoder decodeObjectForKey:@"text"];
    VVTextLayout *textLayout = [VVTextLayout vv_layoutWithContainer:container text:text];
    return textLayout;
}

#pragma mark - Init

// 构建文本布局模型
+ (VVTextLayout *)vv_layoutWithContainer:(VVTextContainer *)container text:(NSAttributedString *)text {
    if (!text || !container) {
        return nil;
    }

    NSMutableAttributedString *mutableAtrributedText = text.mutableCopy;
    NSInteger maxNumberOfLines = container.maxNumberOfLines;
    CGPathRef containerPath = container.path.CGPath;

    // 创建framesetter（通过typesetter 和 通过字符串）
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((__bridge CFTypeRef) mutableAtrributedText);
    CFRange cfRange = CFRangeMake(0, (CFIndex) [mutableAtrributedText length]);
    NSInteger originLength = cfRange.length;

    CGRect containerBoudingBox = CGPathGetPathBoundingBox(containerPath);
    CGSize suggestSize = _getSuggetSizeAndRange(ctFrameSetter,
            mutableAtrributedText,
            containerBoudingBox.size,
            maxNumberOfLines,
            &cfRange);
    NSInteger realLength = cfRange.length;
    BOOL needTruncation = NO;
    if (originLength != realLength) {
        needTruncation = YES;
    }
    CGMutablePathRef suggetPath = CGPathCreateMutable();

    CGRect suggestRect = {
            containerBoudingBox.origin, {
                    containerBoudingBox.size.width,
                    suggestSize.height
            }
    };

    if (containerBoudingBox.size.height != CGFLOAT_MAX) {
        switch (container.vericalAlignment) {
            case VVTextVericalAlignmentTop:
                break;
            case VVTextVericalAlignmentCenter:
                suggestRect = CGRectMake(suggestRect.origin.x,
                        suggestRect.origin.y + (containerBoudingBox.size.height - suggestRect.size.height) / 2.0f,
                        suggestRect.size.width,
                        suggestRect.size.height);
                break;
            case VVTextVericalAlignmentBottom:
                suggestRect = CGRectMake(suggestRect.origin.x,
                        suggestRect.origin.y + containerBoudingBox.size.height - suggestRect.size.height,
                        suggestRect.size.width,
                        suggestRect.size.height);
                break;
        }
    }

    CGPathAddRect(suggetPath, NULL, suggestRect);

    /*
     创建frame
     四个参数：
     framesetter：生成frame的工厂
     range：设置多大就显示多少字符。设置为0时，完整显示。
     path：
     frameAttributes：额外控制frame的属性字典。
    */
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter, cfRange, suggetPath, NULL);

    NSInteger rowIndex = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0.0f, -CGFLOAT_MAX, 0.0f, 0.0f);
    CGPoint lastPosition = CGPointMake(0.0f, -CGFLOAT_MAX);
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    CFArrayRef ctLines = CTFrameGetLines(ctFrame);
    CFIndex lineCount = CFArrayGetCount(ctLines);
    CGPoint *lineOrigins = NULL;
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    }

    BOOL isNeedStroke = NO;
    CGRect textBoundingRect = CGRectZero;
    NSUInteger lineCurrentIndex = 0;
    NSMutableArray *highlights = [[NSMutableArray alloc] init];
    NSMutableArray *backgroundColors = [[NSMutableArray alloc] init];
    NSMutableArray *boundingStrokes = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        CFIndex runCount = CFArrayGetCount(ctRuns);
        if (!ctRuns || runCount == 0) {
            continue;
        }

        for (NSUInteger i = 0; i < runCount; i++) {
            CTRunRef run = CFArrayGetValueAtIndex(ctRuns, i);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) {
                continue;
            }

            NSDictionary *attributes = (id) CTRunGetAttributes(run);
            {
                VVTextHighlight *highlight = attributes[VVTextLinkAttributedName];
                if (highlight) {
                    if (highlight.type == VVTextHighLightTypeWholeText) {
                        NSArray *highlightPositions = @[[NSValue valueWithCGRect:suggestRect]];
                        highlight.positions = highlightPositions;
                    } else {
                        NSArray *highlightPositions = [self _highlightPositionsWithCtFrame:ctFrame range:highlight.range];
                        highlight.positions = highlightPositions;
                    }

                    BOOL isContain = NO;
                    for (VVTextHighlight *one in highlights) {
                        if ([one isEqual:highlight]) {
                            isContain = YES;
                        }
                    }
                    if (!isContain) {
                        [highlights addObject:highlight];
                    }
                }
            }

            {
                VVTextHighlight *highlight = attributes[VVTextLongPressAttributedName];
                if (highlight) {
                    if (highlight.type == VVTextHighLightTypeLongPress) {
                        NSArray *highlightPositions = @[[NSValue valueWithCGRect:suggestRect]];
                        highlight.positions = highlightPositions;
                    }

                    BOOL isContain = NO;
                    for (VVTextHighlight *one in highlights) {
                        if ([one isEqual:highlight]) {
                            isContain = YES;
                        }
                    }
                    if (!isContain) {
                        [highlights addObject:highlight];
                    }
                }
            }

            VVTextBackgroundColor *color = attributes[VVTextBackgroundColorAttributedName];
            if (color) {
                NSArray *backgroundsPositions = [self _highlightPositionsWithCtFrame:ctFrame range:color.range];
                color.positions = backgroundsPositions;
                if (![backgroundColors containsObject:color]) {
                    [backgroundColors addObject:color];
                }
            }

            VVTextBoundingStroke *boundingStroke = attributes[VVTextBoundingStrokeAttributedName];
            if (boundingStroke) {
                NSArray *boundingStrokePositions = [self _highlightPositionsWithCtFrame:ctFrame range:color.range];
                boundingStroke.positions = boundingStrokePositions;
                if (![boundingStrokes containsObject:boundingStroke]) {
                    [boundingStrokes addObject:boundingStroke];
                }
            }
            VVTextStroke *textStroke = attributes[VVTextStrokeAttributedName];
            if (textStroke) {
                isNeedStroke = YES;
            }
        }

        CGPoint ctLineOrigin = lineOrigins[i];
        CGPoint position;
        position.x = suggestRect.origin.x + ctLineOrigin.x;
        position.y = suggestRect.size.height + suggestRect.origin.y - ctLineOrigin.y;

        VVTextLine *line = [VVTextLine vv_textLineWithCTlineRef:ctLine lineOrigin:position];
        CGRect rect = line.frame;
        BOOL newRow = YES;
        if (position.x != lastPosition.x) {
            if (rect.size.height > lastRect.size.height) {
                if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) {
                    newRow = NO;
                }
            } else {
                if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) {
                    newRow = NO;
                }
            }
        }
        if (newRow) {
            rowIndex++;
        }
        lastRect = rect;
        lastPosition = position;
        line.index = lineCurrentIndex;
        line.row = rowIndex;
        [lines addObject:line];
        rowCount = rowIndex + 1;
        lineCurrentIndex++;
        if (i == 0) {
            textBoundingRect = rect;
        } else {
            textBoundingRect = CGRectUnion(textBoundingRect, rect);
        }
    }

    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    NSMutableArray *attachmentRanges = [[NSMutableArray alloc] init];
    NSMutableArray *attachmentRects = [[NSMutableArray alloc] init];
    NSMutableSet *attachmentContentsSet = [[NSMutableSet alloc] init];

    for (NSUInteger i = 0; i < lines.count; i++) {
        VVTextLine *line = lines[i];
        if (line.attachments.count > 0) {
            [attachments addObjectsFromArray:line.attachments];
            [attachmentRanges addObjectsFromArray:line.attachmentRanges];
            [attachmentRects addObjectsFromArray:line.attachmentRects];
            for (VVTextAttachment *attachment in line.attachments) {
                if (attachment.content) {
                    [attachmentContentsSet addObject:attachment.content];
                }
            }
        }
    }

    suggestRect = CGRectMake(suggestRect.origin.x - container.edgeInsets.left,
            suggestRect.origin.y - container.edgeInsets.top,
            suggestRect.size.width + container.edgeInsets.left + container.edgeInsets.right,
            suggestRect.size.height + container.edgeInsets.top + container.edgeInsets.bottom);

    VVTextLayout *layout = [[VVTextLayout alloc] init];
    layout.needStrokeDraw = isNeedStroke;
    layout.container = container;
    layout.text = mutableAtrributedText;
    layout.suggestPathRef = suggetPath;
    layout.cgPath = [UIBezierPath bezierPathWithRect:suggestRect].CGPath;
    layout.ctFrameSetter = ctFrameSetter;
    layout.ctFrame = ctFrame;
    layout.linesArray = lines;
    layout.suggestSize = suggestSize;
    layout.cgPathBox = containerBoudingBox;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingRect.size;
    layout.textHighlights = [highlights copy];
    layout.backgroundColors = [backgroundColors copy];
    layout.boudingStrokes = [boundingStrokes copy];
    layout.attachments = [attachments copy];
    layout.attachmentRanges = [attachmentRanges copy];
    layout.attachmentRects = [attachmentRects copy];
    layout.attachmentContentsSet = [attachmentContentsSet copy];
    layout.numberOfLines = layout.linesArray.count;
    layout.needTruncation = needTruncation;

    if (layout.backgroundColors.count > 0) layout.needTextBackgroundColorDraw = YES;
    if (layout.boudingStrokes.count > 0) layout.needBoudingStrokeDraw = YES;
    if (layout.attachments.count > 0) layout.needAttachmentDraw = YES;

    if (lineOrigins) {
        free(lineOrigins);
    }

    return layout;
}

- (id)init {
    self = [super init];
    if (self) {
        self.needDebugDraw = NO;
    }
    return self;
}

- (void)dealloc {
    if (self.ctFrame) {
        CFRelease(self.ctFrame);
    }
    if (self.ctFrameSetter) {
        CFRelease(self.ctFrameSetter);
    }
    if (self.suggestPathRef) {
        CFRelease(self.suggestPathRef);
    }
}

#pragma mark - Draw & Remove

- (void)vv_drawIncontext:(CGContextRef)context
                    size:(CGSize)size
                   point:(CGPoint)point
           containerView:(UIView *)containerView
          containerLayer:(CALayer *)containerLayer
             isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelld {

    if (self.isNeedTextBackgroundColorDraw) {
        [self _drawTextBackgroundColorInContext:context
                                     textLayout:self
                                           size:size
                                          point:point
                                    isCancelled:isCancelld];
    }

    if (self.isNeedBoudingStrokeDraw) {
        [self _drawTextBoudingStrokeInContext:context
                                   textLayout:self
                                         size:size
                                        point:point
                                  isCancelled:isCancelld];
    }

    if (self.isNeedDebugDraw) {
        [self _drawDebugInContext:context
                       textLayout:self
                             size:size
                            point:point
                      isCancelled:isCancelld];
    }

    [self _drawTextInContext:context
                  textLayout:self
                        size:size
                       point:point
                 isCancelled:isCancelld];

    if (self.isNeedAttachmentDraw) {
        [self _drawAttachmentsIncontext:context
                              textLayou:self
                                   size:size
                                  point:point
                          containerView:containerView
                         containerLayer:containerLayer
                            isCancelled:isCancelld];
    }
}

- (void)_drawTextBackgroundColorInContext:(CGContextRef)context
                               textLayout:(VVTextLayout *)textLayout
                                     size:(CGSize)size
                                    point:(CGPoint)point
                              isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelld {

    [textLayout.backgroundColors enumerateObjectsUsingBlock:^(VVTextBackgroundColor *
    _Nonnull background,
            NSUInteger idx,
            BOOL *_Nonnull stop) {
        if (isCancelld()) {
            return;
        }
        for (NSValue *value in background.positions) {
            if (isCancelld()) {
                break;
            }
            CGRect rect = [value CGRectValue];
            CGRect adjustRect = CGRectMake(point.x + rect.origin.x, point.y + rect.origin.y, rect.size.width, rect.size.height);
            UIBezierPath *beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect cornerRadius:2.0f];
            [background.backgroundColor setFill];
            [beizerPath fill];
        }
    }];
}

- (void)_drawTextBoudingStrokeInContext:(CGContextRef)context
                             textLayout:(VVTextLayout *)textLayout
                                   size:(CGSize)size
                                  point:(CGPoint)point
                            isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelld {

    [textLayout.boudingStrokes enumerateObjectsUsingBlock:^(VVTextBoundingStroke *_Nonnull boundingStroke,
            NSUInteger idx,
            BOOL *_Nonnull stop) {
        if (isCancelld()) {
            return;
        }
        for (NSValue *value in boundingStroke.positions) {
            if (isCancelld()) {
                break;
            }
            CGRect rect = [value CGRectValue];
            CGRect adjustRect = CGRectMake(point.x + rect.origin.x, point.y + rect.origin.y, rect.size.width, rect.size.height);

            UIBezierPath *beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect cornerRadius:2.0f];
            [boundingStroke.strokeColor setStroke];
            [beizerPath setLineWidth:1.0f];
            [beizerPath stroke];
        }
    }];
}

- (void)_drawDebugInContext:(CGContextRef)context
                 textLayout:(VVTextLayout *)textLayout
                       size:(CGSize)size
                      point:(CGPoint)point
                isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelld {

    CGRect r = CGRectOffset(textLayout.cgPathBox, point.x, point.y);
    CGContextAddRect(context, CGRectMake(r.origin.x - 0.2f,
            r.origin.y - 1.0f,
            r.size.width + 5.0f,
            r.size.height + 2.0f));
    CGContextSetLineWidth(context, 0.2f);
    CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextStrokePath(context);


    CGContextAddRect(context, CGRectOffset(textLayout.textBoundingRect, point.x, point.y));
    CGContextSetFillColorWithColor(context, VV_COLOR(44.0f, 189.0f, 230.0f, 0.1f).CGColor);
    CGContextFillPath(context);

    [textLayout.linesArray enumerateObjectsUsingBlock:^(VVTextLine *_Nonnull line,
            NSUInteger idx,
            BOOL *_Nonnull stop) {
        if (isCancelld()) {
            return;
        }
        CGContextMoveToPoint(context,
                line.lineOrigin.x + point.x,
                (line.lineOrigin.y + point.y + 1.0f));

        CGContextAddLineToPoint(context,
                line.lineOrigin.x + point.x + line.lineWidth,
                (line.lineOrigin.y + point.y + 1.0f));
        CGContextSetLineWidth(context, 1.0f);//base line
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextStrokePath(context);

        for (VVTextGlyph *glyph in line.glyphs) {
            CGContextAddRect(context, CGRectMake(point.x + line.lineOrigin.x + glyph.position.x,
                    line.lineOrigin.y + point.y - glyph.ascent,
                    glyph.width,
                    glyph.ascent + glyph.descent));
            CGContextSetLineWidth(context, 0.2f);
            CGContextSetStrokeColorWithColor(context,
                    [UIColor orangeColor].CGColor);
            CGContextStrokePath(context);
        }
    }];


    [textLayout.textHighlights enumerateObjectsUsingBlock:^(VVTextHighlight *_Nonnull highlight,
            NSUInteger idx,
            BOOL *_Nonnull stop) {
        if (isCancelld()) {
            return;
        }
        for (NSValue *rectValue in highlight.positions) {
            if (isCancelld()) {
                break;
            }

            CGRect rect = [rectValue CGRectValue];
            CGRect adjustRect = CGRectOffset(rect, point.x, point.y);
            UIBezierPath *beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect
                                                                  cornerRadius:2.0f];
            [VV_COLOR(133.0f, 116.0f, 89.0f, 0.25f) setFill];
            [beizerPath fill];
        }
    }];
}

- (void)_drawTextInContext:(CGContextRef)context
                textLayout:(VVTextLayout *)textLayout
                      size:(CGSize)size
                     point:(CGPoint)point
               isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelld {

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    NSArray *lines = textLayout.linesArray;
    [lines enumerateObjectsUsingBlock:^(VVTextLine *_Nonnull line, NSUInteger idx, BOOL *_Nonnull stop) {
        if (isCancelld()) {
            return;
        }
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSetTextPosition(context, line.lineOrigin.x, size.height - line.lineOrigin.y);
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSUInteger j = 0; j < CFArrayGetCount(runs); j++) {
            if (isCancelld()) {
                break;
            }
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            if (textLayout.isNeedStrokeDraw) {
                NSDictionary *attributes = (id) CTRunGetAttributes(run);
                VVTextStroke *textStroke = attributes[VVTextStrokeAttributedName];
                if (textStroke) {
                    [self _drawGlyphsInContext:context run:run];
                } else {
                    CTRunDraw(run, context, CFRangeMake(0, 0));
                }
            } else {
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    }];
    CGContextRestoreGState(context);
}

- (void)_drawGlyphsInContext:(CGContextRef)context
                         run:(CTRunRef)run {
    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
    VVTextStroke *textStroke = CFDictionaryGetValue(runAttrs, VVTextStrokeAttributedName);
    if (!textStroke) {
        return;
    }

    CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
    if (!runFont) {
        return;
    }

    NSUInteger glyphCount = CTRunGetGlyphCount(run);
    if (glyphCount <= 0) {
        return;
    }
    CGGlyph glyphs[glyphCount];
    CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
    CGPoint glyphPositions[glyphCount];
    CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);

    CGColorRef strokeColor = textStroke.strokeColor.CGColor;
    CGFloat strokeWidth = textStroke.strokeWidth;
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    CGContextSetStrokeColorWithColor(context, strokeColor);
    CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabsf(strokeWidth * 0.01f));
    CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
    CGContextSetFont(context, cgFont);
    CGContextSetFontSize(context, CTFontGetSize(runFont));
    CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
    CGFontRelease(cgFont);
    CGContextRestoreGState(context);
}

- (void)_drawAttachmentsIncontext:(CGContextRef)context
                        textLayou:(VVTextLayout *)textLayout
                             size:(CGSize)size
                            point:(CGPoint)point
                    containerView:(UIView *)containerView
                   containerLayer:(CALayer *)containerLayer
                      isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelld {

    for (NSUInteger i = 0; i < textLayout.attachments.count; i++) {
        if (isCancelld()) {
            break;
        }

        VVTextAttachment *attachment = textLayout.attachments[i];
        if (!attachment.content) {
            continue;
        }

        UIImage *image = nil;
        UIView *view = nil;
        CALayer *layer = nil;

        if ([attachment.content isKindOfClass:[UIImage class]]) {
            image = attachment.content;
        } else if ([attachment.content isKindOfClass:[UIView class]]) {
            view = attachment.content;
        } else if ([attachment.content isKindOfClass:[CALayer class]]) {
            layer = attachment.content;
        }

        if ((!image && !view && !layer) ||
                (image && !context) ||
                (view && !containerView) ||
                (layer && !containerLayer)) {
            continue;
        }

        //TODO 开启主线程检测通不通过，且渲染变慢。
        CGSize asize = image ? image.size : view ? view.bounds.size : layer.bounds.size;
        CGRect rect = textLayout.attachmentRects[i].CGRectValue;
        rect = UIEdgeInsetsInsetRect(rect, attachment.contentEdgeInsets);
        rect = [VVCGRectTransform vv_CGRectFitWithContentMode:attachment.contentMode
                                                         rect:rect
                                                         size:asize];
        rect = CGRectStandardize(rect);
        rect.origin.x += point.x;
        rect.origin.y += point.y;

        //图片类型的附件直接绘制到VVAsyncImageView上
        if (image) {
            CGImageRef ref = image.CGImage;
            if (ref) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0, CGRectGetMaxY(rect) + CGRectGetMinY(rect));
                CGContextScaleCTM(context, 1, -1);
                CGContextDrawImage(context, rect, ref);
                CGContextRestoreGState(context);
            }

        } else if (view) {
            dispatch_main_async_safe(^{
                view.frame = rect;
                [containerView addSubview:view];

                if (attachment.userInfo && attachment.userInfo[@"URL"]) {
                    VVAsyncImageView *asyncImageView = (VVAsyncImageView *) view;
                    [asyncImageView sd_setImageWithURL:attachment.userInfo[@"URL"] placeholderImage:nil];
                }
            });

        } else if (layer) {
            dispatch_main_async_safe(^{
                layer.frame = rect;
                [containerLayer addSublayer:layer];

                if (attachment.userInfo && attachment.userInfo[@"URL"]) {
                    [layer sd_internalSetImageWithURL:attachment.userInfo[@"URL"]
                                     placeholderImage:nil
                                              options:0
                                              context:nil
                                        setImageBlock:NULL
                                             progress:NULL
                                            completed:NULL];
                }
            });
        }
    }
}

- (void)vv_removeAttachmentFromSuperViewOrLayer {
    for (VVTextAttachment *attachment in self.attachments) {
        @autoreleasepool {
            if ([attachment.content isKindOfClass:[UIView class]]) {
                dispatch_main_async_safe(^{
                    UIView *view = attachment.content;
                    [view removeFromSuperview];
                });
            } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                dispatch_main_async_safe(^{
                    CALayer *layer = attachment.content;
                    [layer removeFromSuperlayer];
                });
            }
        }
    }
}

#pragma mark - Private

+ (NSArray<NSValue *> *)_highlightPositionsWithCtFrame:(CTFrameRef)ctFrame
                                                 range:(NSRange)selectRange {
    // 获取用于创建frame的path
    CGPathRef path = CTFrameGetPath(ctFrame);
    CGRect boundsRect = CGPathGetBoundingBox(path);
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    NSInteger selectionStartPosition = selectRange.location;
    NSInteger selectionEndPosition = NSMaxRange(selectRange);
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    if (!lines) {
        return nil;
    }

    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(0, boundsRect.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), origins);

    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);

        if ([self _isPosition:selectionStartPosition inRange:range] &&
                [self _isPosition:selectionEndPosition inRange:range]) {

            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset,
                    linePoint.y - descent,
                    offset2 - offset,
                    ascent + descent);

            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                    rect.origin.y + boundsRect.origin.y,
                    rect.size.width,
                    rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
            break;
        }

        if ([self _isPosition:selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            width = (CGFloat) CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset,
                    linePoint.y - descent,
                    width - offset,
                    ascent + descent);

            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                    rect.origin.y + boundsRect.origin.y,
                    rect.size.width,
                    rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];

        } else if (selectionStartPosition < range.location &&
                selectionEndPosition >= range.location + range.length) {

            CGFloat ascent, descent, leading, width;
            width = (CGFloat) CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x,
                    linePoint.y - descent,
                    width,
                    ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                    rect.origin.y + boundsRect.origin.y,
                    rect.size.width,
                    rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];

        } else if (selectionStartPosition < range.location &&
                [self _isPosition:selectionEndPosition inRange:range]) {

            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            width = (CGFloat) CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, offset, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                    rect.origin.y + boundsRect.origin.y,
                    rect.size.width,
                    rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
        }
    }
    return positions;
}

+ (BOOL)_isPosition:(NSInteger)position inRange:(CFRange)range {
    return (position >= range.location && position < range.location + range.length);
}


@end


static inline CGSize _getSuggetSizeAndRange(CTFramesetterRef framesetter,
        NSAttributedString *attributedString,
        CGSize size,
        NSUInteger numberOfLines,
        CFRange *rangeToSize) {

    CGSize constraints = CGSizeMake(size.width, MAXFLOAT);
    if (numberOfLines > 0) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, MAXFLOAT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);

        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex) numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            *rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }

    // 获取展示一串文字需要多大的空间
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, *rangeToSize, NULL, constraints, NULL);
    return CGSizeMake(ceilf(suggestedSize.width), ceilf(suggestedSize.height));
}

