
#import "VVTextLine.h"
#import "VVTextAttachment.h"
#import <objc/runtime.h>
#import "VVRichTextUtils.h"
#import "VVRichTextDefine.h"

@interface VVTextLine ()

@property(nonatomic, assign) CTLineRef CTLine;
@property(nonatomic, assign) CGPoint lineOrigin;

@property(nonatomic, assign) NSRange range;
@property(nonatomic, assign) CGRect frame;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign) CGFloat bottom;
@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat right;

@property(nonatomic, assign) CGFloat ascent;
@property(nonatomic, assign) CGFloat descent;
@property(nonatomic, assign) CGFloat leading;
@property(nonatomic, assign) CGFloat lineWidth;
@property(nonatomic, assign) CGFloat trailingWhitespaceWidth;

@property(nonatomic, copy) NSArray<VVTextGlyph *> *glyphs;
@property(nonatomic, copy) NSArray<VVTextAttachment *> *attachments;
@property(nonatomic, copy) NSArray<NSValue *> *attachmentRanges;
@property(nonatomic, copy) NSArray<NSValue *> *attachmentRects;
@property(nonatomic, assign) CGFloat firstGlyphPosition;

@end


@implementation VVTextLine

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:(__nonnull id) self.CTLine forKey:@"CTLine"];
    [aCoder encodeCGPoint:self.lineOrigin forKey:@"lineOrigin"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    CTLineRef CTLine = (__bridge CTLineRef) ([aDecoder decodeObjectForKey:@"CTLine"]);
    CGPoint lineOrigin = [aDecoder decodeCGPointForKey:@"lineOrigin"];
    VVTextLine *one = [VVTextLine vv_textLineWithCTlineRef:CTLine lineOrigin:lineOrigin];
    return one;
}

#pragma mark - Init

+ (id)vv_textLineWithCTlineRef:(CTLineRef)CTLine lineOrigin:(CGPoint)lineOrigin {
    if (!CTLine) {
        return nil;
    }
    VVTextLine *line = [[VVTextLine alloc] init];
    line.CTLine = CTLine;
    line.lineOrigin = lineOrigin;
    return line;
}

- (id)init {
    self = [super init];
    if (self) {
        self.lineWidth = 0.0f;
        self.ascent = 0.0f;
        self.descent = 0.0f;
        self.leading = 0.0f;
        self.firstGlyphPosition = 0.0f;
        self.trailingWhitespaceWidth = 0.0f;
        self.range = NSMakeRange(0, 0);
    }
    return self;
}

- (void)dealloc {
    if (self.CTLine) {
        CFRelease(self.CTLine);
    }
}

#pragma mark - Setter

- (void)setCTLine:(CTLineRef)CTLine {
    if (_CTLine != CTLine) {
        if (_CTLine) {
            CFRelease(_CTLine);
        }
        _CTLine = CFRetain(CTLine);
        if (_CTLine) {
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;

            self.lineWidth = CTLineGetTypographicBounds(_CTLine, &ascent, &descent, &leading);
            self.ascent = ascent;
            self.descent = descent;
            self.leading = leading;
            CFRange range = CTLineGetStringRange(_CTLine);
            self.range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                self.firstGlyphPosition = pos.x;
            } else {
                self.firstGlyphPosition = 0.0f;
            }
            self.trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        }
        [self _calculatesTheBounds];
    }
}

- (void)setLineOrigin:(CGPoint)lineOrigin {
    _lineOrigin = lineOrigin;
    [self _calculatesTheBounds];
}

#pragma mark - Calculates

- (void)_calculatesTheBounds {
    self.frame = CGRectMake(self.lineOrigin.x + self.firstGlyphPosition,
            self.lineOrigin.y - self.ascent,
            self.lineWidth,
            self.ascent + self.descent);
    if (!self.CTLine) {
        return;
    }
    CFArrayRef runs = CTLineGetGlyphRuns(self.CTLine);
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) {
        return;
    }

    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    NSMutableArray *attachmentRanges = [[NSMutableArray alloc] init];
    NSMutableArray *attachmentRects = [[NSMutableArray alloc] init];
    NSMutableArray *glyphsArray = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < runCount; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) {
            continue;
        }
        CGPoint runPosition = CGPointZero;
        CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
        CGFloat ascent, descent, leading, runWidth;
        CGRect runTypoBounds;

        runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
        runPosition.x += self.lineOrigin.x;
        runPosition.y = self.lineOrigin.y - runPosition.y;
        runTypoBounds = CGRectMake(runPosition.x, runPosition.y - ascent, runWidth, ascent + descent);

        NSRange runRange = NSMakeRange(CTRunGetStringRange(run).location, CTRunGetStringRange(run).length);

        {
            CGGlyph glyphs[glyphCount];
            CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);

            CGPoint glyphPositions[glyphCount];
            CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);

            CGSize glyphAdvances[glyphCount];
            CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances);

            for (NSInteger i = 0; i < glyphCount; i++) {
                VVTextGlyph *glyph = [[VVTextGlyph alloc] init];
                glyph.glyph = glyphs[i];
                glyph.position = glyphPositions[i];
                glyph.leading = leading;
                glyph.ascent = ascent;
                glyph.descent = descent;
                glyph.width = glyphAdvances[i].width;
                glyph.height = glyphAdvances[i].height;
                [glyphsArray addObject:glyph];
            }
        }

        NSDictionary *attributes = (id) CTRunGetAttributes(run);
        VVTextAttachment *attachment = [attributes objectForKey:VVTextAttachmentAttributeName];
        if (attachment) {
            [attachments addObject:attachment];
            [attachmentRanges addObject:[NSValue valueWithRange:runRange]];
            [attachmentRects addObject:[NSValue valueWithCGRect:runTypoBounds]];
        }
    }
    self.attachments = [attachments copy];
    self.attachmentRanges = [attachmentRanges copy];
    self.attachmentRects = [attachmentRects copy];
    self.glyphs = [glyphsArray copy];
}

#pragma mark - Getter

- (CGSize)size {
    return self.frame.size;
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

- (CGFloat)top {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)left {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)right {
    return CGRectGetMaxX(self.frame);
}

@end
