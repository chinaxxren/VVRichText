

#import "NSMutableAttributedString+VVRichText.h"

#import "VVTextAttachment.h"
#import "VVTextRunDelegate.h"

@implementation NSMutableAttributedString (VVRichText)

#pragma mark -

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
    [self setAttribute:NSForegroundColorAttributeName value:textColor range:range];
}

- (void)setTextBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    VVTextBackgroundColor *textBackground = [[VVTextBackgroundColor alloc] init];
    textBackground.backgroundColor = backgroundColor;
    textBackground.range = range;
    [self setAttribute:VVTextBackgroundColorAttributedName value:textBackground range:range];
}

- (void)setTextBoundingStrokeColor:(UIColor *)boundingStrokeColor range:(NSRange)range {
    VVTextBoundingStroke *boundingStroke = [[VVTextBoundingStroke alloc] init];
    boundingStroke.strokeColor = boundingStrokeColor;
    boundingStroke.range = range;
    [self setAttribute:VVTextBoundingStrokeAttributedName value:boundingStroke range:range];
}

- (void)setFont:(UIFont *)font range:(NSRange)range {
    [self setAttribute:NSFontAttributeName value:font range:range];
}

- (void)setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range {
    CFNumberRef charSpacingNum = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &characterSpacing);
    if (charSpacingNum != nil) {
        [self setAttribute:(NSString *) kCTKernAttributeName value:(__bridge id) charSpacingNum range:range];
        CFRelease(charSpacingNum);
    }
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle underlineColor:(UIColor *)underlineColor range:(NSRange)range {
    [self setAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    [self setAttribute:NSUnderlineStyleAttributeName value:@(underlineStyle) range:range];
}

- (void)setStrokeColor:(UIColor *)strokeColor strokeWidth:(CGFloat)strokeWidth range:(NSRange)range {
    VVTextStroke *textStroke = [[VVTextStroke alloc] init];
    textStroke.strokeColor = strokeColor;
    textStroke.strokeWidth = strokeWidth;
    textStroke.range = range;
    [self setAttribute:VVTextStrokeAttributedName value:textStroke range:range];
}

#pragma mark - ParagraphStyle

- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle *style = value.mutableCopy;
                          [style setLineSpacing:lineSpacing];
                          [self setParagraphStyle:style range:subRange];
                      } else {
                          NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineSpacing:lineSpacing];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle *style = value.mutableCopy;
                          [style setAlignment:textAlignment];
                          [self setParagraphStyle:style range:subRange];
                      } else {
                          NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                          [style setAlignment:textAlignment];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle *style = value.mutableCopy;
                          [style setLineBreakMode:lineBreakMode];
                          [self setParagraphStyle:style range:subRange];
                      } else {
                          NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineBreakMode:lineBreakMode];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}


- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    [self setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

#pragma mark - Link & Attachment

- (void)addLinkForWholeTextWithData:(id)data linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor {
    VVTextHighlight *highlight = [[VVTextHighlight alloc] init];
    highlight.hightlightColor = highLightColor;
    highlight.linkColor = linkColor;
    highlight.content = data;
    highlight.type = VVTextHighLightTypeWholeText;

    NSRange range;
    NSMutableArray *existLinkRanges = [[NSMutableArray alloc] init];
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((__bridge CFTypeRef) self);
    CGMutablePathRef cgPath = CGPathCreateMutable();
    CGPathAddRect(cgPath, NULL, CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX));
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter, CFRangeMake(0, self.length), cgPath, NULL);
    CFRelease(cgPath);
    CFRelease(ctFrameSetter);
    CFArrayRef ctLines = CTFrameGetLines(ctFrame);
    CFIndex lineCount = CFArrayGetCount(ctLines);
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
            VVTextHighlight *linkHighlight = attributes[VVTextLinkAttributedName];
            if (!linkHighlight) {
                continue;
            }
            NSRange existLinkRange = linkHighlight.range;
            NSValue *rValue = [NSValue valueWithRange:existLinkRange];
            if (![existLinkRanges containsObject:rValue]) {
                [existLinkRanges addObject:rValue];
            }
        }
    }
    if (existLinkRanges.count != 0) {
        for (NSInteger i = 0; i < existLinkRanges.count; i++) {
            NSValue *value = existLinkRanges[i];
            NSRange currentRange = [value rangeValue];
            NSRange nextRange;
            if (i + 1 < existLinkRanges.count) {
                nextRange = [existLinkRanges[i + 1] rangeValue];
                NSInteger length = nextRange.location - (currentRange.location + currentRange.length) - 1;
                NSInteger location = (currentRange.location + currentRange.length);
                range = NSMakeRange(location, length);
            } else {
                NSInteger location = (currentRange.location + currentRange.length);
                NSInteger length = self.length - (currentRange.location + currentRange.length);
                range = NSMakeRange(location, length);
            }
            [self setAttribute:VVTextLinkAttributedName value:highlight range:range];
            if (linkColor) {
                [self setAttribute:NSForegroundColorAttributeName value:linkColor range:range];
            }
        }
    } else {
        range = NSMakeRange(0, self.length);
        [self setAttribute:VVTextLinkAttributedName value:highlight range:range];
        if (linkColor) {
            [self setAttribute:NSForegroundColorAttributeName value:linkColor range:range];
        }
    }
    if (ctFrame) {
        CFRelease(ctFrame);
    }
}

- (void)addLongPressActionWithData:(id)data highLightColor:(UIColor *)highLightColor {
    VVTextHighlight *highlight = [[VVTextHighlight alloc] init];
    highlight.hightlightColor = highLightColor;
    highlight.content = data;
    highlight.type = VVTextHighLightTypeLongPress;
    highlight.range = NSMakeRange(0, self.length);
    [self setAttribute:VVTextLongPressAttributedName value:highlight range:NSMakeRange(0, self.length)];
}

- (void)addLinkWithData:(id)data range:(NSRange)range linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor {
    VVTextHighlight *highlight = [[VVTextHighlight alloc] init];
    highlight.hightlightColor = highLightColor;
    highlight.linkColor = linkColor;
    highlight.content = data;
    highlight.type = VVTextHighLightTypeNormal;
    highlight.range = NSMakeRange(range.location, range.length);
    [self setAttribute:VVTextLinkAttributedName value:highlight range:range];
    [self setAttribute:NSForegroundColorAttributeName value:linkColor range:range];
}

+ (NSMutableAttributedString *)vv_textAttachmentStringWithContent:(id)content
                                                      contentMode:(UIViewContentMode)contentMode
                                                           ascent:(CGFloat)ascent
                                                          descent:(CGFloat)descent
                                                            width:(CGFloat)width {
    unichar objectReplacementChar = 0xFFFC;
    NSString *contentString = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:contentString];
    VVTextAttachment *attachment = [[VVTextAttachment alloc] init];
    attachment.content = content;
    attachment.contentMode = contentMode;
    [space addAttribute:VVTextAttachmentAttributeName value:attachment range:NSMakeRange(0, space.length)];
    VVTextRunDelegate *delegate = [[VVTextRunDelegate alloc] init];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef) space, CFRangeMake(0, space.length), kCTRunDelegateAttributeName, delegateRef);
    if (delegate) {
        CFRelease(delegateRef);
    }

    return space;
}

+ (NSMutableAttributedString *)vv_textAttachmentStringWithContent:(id)content
                                                         userInfo:(NSDictionary *)userInfo
                                                      contentMode:(UIViewContentMode)contentMode
                                                           ascent:(CGFloat)ascent
                                                          descent:(CGFloat)descent
                                                            width:(CGFloat)width {
    unichar objectReplacementChar = 0xFFFC;
    NSString *contentString = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:contentString];
    VVTextAttachment *attachment = [[VVTextAttachment alloc] init];
    attachment.content = content;
    attachment.contentMode = contentMode;
    attachment.userInfo = userInfo;
    [space addAttribute:VVTextAttachmentAttributeName value:attachment range:NSMakeRange(0, space.length)];
    VVTextRunDelegate *delegate = [[VVTextRunDelegate alloc] init];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef) space, CFRangeMake(0, space.length),
            kCTRunDelegateAttributeName, delegateRef);
    if (delegate) {
        CFRelease(delegateRef);
    }
    return space;
}

#pragma mark -

- (void)setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) {
        return;
    }

    if (value && ![NSNull isEqual:value]) {
        [self addAttribute:name value:value range:range];
    } else {
        [self removeAttribute:name range:range];
    }
}

- (void)removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

@end
