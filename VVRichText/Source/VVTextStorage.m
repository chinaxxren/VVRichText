
#import "VVTextStorage.h"

#import "VVAsyncImageView.h"
#import "VVRichText.h"

@interface VVTextStorage ()

@property(nonatomic, strong) VVTextLayout *textLayout;
@property(nonatomic, assign) CGSize suggestSize;//建议的绘制大小
@property(nonatomic, assign) NSInteger numberOfLines;//文本的实际行数
@property(nonatomic, assign) BOOL isTruncation;//是否折叠

@end


@implementation VVTextStorage

@synthesize frame = _frame;
@synthesize position = _position;
@synthesize text = _text;


#pragma mark - Override Hash & isEqual

- (BOOL)isEqual:(id)object {
    if (!object || ![object isMemberOfClass:[VVTextStorage class]]) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    VVTextStorage *textStorage = (VVTextStorage *) object;
    return [textStorage.text isEqualToString:self.text] && CGRectEqualToRect(textStorage.frame, self.frame);
}

- (NSUInteger)hash {
    long v1 = (long) self.text;
    long v2 = (long) [NSValue valueWithCGRect:self.frame];
    return v1 ^ v2;
}

#pragma mark - Init

+ (VVTextStorage *)vv_textStorageWithTextLayout:(VVTextLayout *)textLayout
                                          frame:(CGRect)frame {
    VVTextStorage *textStorage = [[VVTextStorage alloc] initWithFrame:frame];
    textStorage.textLayout = textLayout;
    return textStorage;
}

+ (VVTextStorage *)vv_textStorageWithText:(NSAttributedString *)attributedText
                                    frame:(CGRect)frame {
    VVTextStorage *textStorage = [[VVTextStorage alloc] initWithFrame:frame];
    VVTextContainer *textContainer = [VVTextContainer vv_textContainerWithSize:frame.size];
    textStorage.textLayout = [VVTextLayout vv_layoutWithContainer:textContainer text:attributedText];
    textStorage.attributedText = [attributedText mutableCopy];
    return textStorage;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self setup];
        self.frame = frame;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.frame = CGRectZero;
    self.position = CGPointZero;
    self.text = nil;
    self.attributedText = nil;
    self.textColor = [UIColor blackColor];
    self.textBackgroundColor = [UIColor clearColor];
    self.font = [UIFont systemFontOfSize:14.0f];
    self.textAlignment = NSTextAlignmentLeft;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.underlineStyle = NSUnderlineStyleNone;
    self.linespacing = 1.0f;
    self.characterSpacing = 0;
    self.textDrawMode = VVTextDrawModeFill;
    self.strokeColor = [UIColor blackColor];
    self.strokeWidth = 1.0f;
    self.textBoundingStrokeColor = nil;
    self.maxNumberOfLine = 0;
    self.needDebug = NO;
    self.vericalAlignment = VVTextVericalAlignmentTop;
}

#pragma mark - Methods

- (void)vv_addLinkForWholeTextStorageWithData:(id)data
                                    linkColor:(UIColor *)linkColor
                               highLightColor:(UIColor *)highLightColor {
    [self.attributedText vv_addLinkForWholeTextWithData:data
                                              linkColor:linkColor
                                         highLightColor:highLightColor];
}

- (void)vv_addLinkForWholeTextStorageWithData:(id)data
                               highLightColor:(UIColor *)highLightColor {
    [self.attributedText vv_addLinkForWholeTextWithData:data
                                              linkColor:nil
                                         highLightColor:highLightColor];
}


- (void)vv_addLinkWithData:(id)data range:(NSRange)range
                 linkColor:(UIColor *)linkColor
            highLightColor:(UIColor *)highLightColor {
    [self.attributedText vv_addLinkWithData:data
                                      range:range
                                  linkColor:linkColor
                             highLightColor:highLightColor];
}


- (void)vv_addLongPressActionWithData:(id)data highLightColor:(UIColor *)highLightColor {
    [self.attributedText vv_addLongPressActionWithData:data highLightColor:highLightColor];
}

- (void)vv_replaceTextWithImage:(UIImage *)image
                    contentMode:(UIViewContentMode)contentMode
                      imageSize:(CGSize)size
                      alignment:(VVTextAttachAlignment)attachAlignment
                          range:(NSRange)range {
    if (!self.attributedText) {
        return;
    }
    CGFloat ascent = 0.0f, descent = 0.0f;
    switch (attachAlignment) {
        case VVTextAttachAlignmentTop: {
            ascent = size.height;
            descent = 0.0f;
        }
            break;
        case VVTextAttachAlignmentCenter: {
            ascent = size.height / 2;
            descent = size.height / 2;
        }
            break;
        case VVTextAttachAlignmentBottom: {
            ascent = 0.0f;
            descent = size.height;
        }
            break;
    }
    NSMutableAttributedString *attachString = [NSMutableAttributedString vv_textAttachmentStringWithContent:image
                                                                                                contentMode:contentMode
                                                                                                     ascent:ascent
                                                                                                    descent:descent
                                                                                                      width:size.width];
    [self.attributedText replaceCharactersInRange:range
                             withAttributedString:attachString];
}


- (void)vv_replaceTextWithImageURL:(NSURL *)URL
                       contentMode:(UIViewContentMode)contentMode
                         imageSize:(CGSize)size
                         alignment:(VVTextAttachAlignment)attachAlignment
                             range:(NSRange)range {
    if (!self.attributedText) {
        return;
    }

    CGFloat ascent = 0.0f, descent = 0.0f;
    switch (attachAlignment) {
        case VVTextAttachAlignmentTop: {
            ascent = size.height;
            descent = 0.0f;
        }
            break;
        case VVTextAttachAlignmentCenter: {
            ascent = size.height / 2;
            descent = size.height / 2;
        }
            break;
        case VVTextAttachAlignmentBottom: {
            ascent = 0.0f;
            descent = size.height;
        }
            break;
    }

    NSDictionary *userInfo;
    if (URL) {
        userInfo = @{@"URL": URL};
    }

    NSMutableAttributedString *attachString = [NSMutableAttributedString vv_textAttachmentStringWithContent:[[VVAsyncImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)]
                                                                                                   userInfo:userInfo
                                                                                                contentMode:contentMode
                                                                                                     ascent:ascent
                                                                                                    descent:descent
                                                                                                      width:size.width];
    [self.attributedText replaceCharactersInRange:range withAttributedString:attachString];
}


- (void)vv_replaceTextWithView:(UIView *)view
                   contentMode:(UIViewContentMode)contentMode
                          size:(CGSize)size
                     alignment:(VVTextAttachAlignment)attachAlignment
                         range:(NSRange)range {
    if (!self.attributedText) {
        return;
    }

    CGFloat ascent = 0.0f, descent = 0.0f;
    switch (attachAlignment) {
        case VVTextAttachAlignmentTop: {
            ascent = size.height;
            descent = 0.0f;
        }
            break;
        case VVTextAttachAlignmentCenter: {
            ascent = size.height / 2;
            descent = size.height / 2;
        }
            break;
        case VVTextAttachAlignmentBottom: {
            ascent = 0.0f;
            descent = size.height;
        }
            break;
    }

    NSMutableAttributedString *attachString = [NSMutableAttributedString vv_textAttachmentStringWithContent:view
                                                                                                contentMode:contentMode
                                                                                                     ascent:ascent
                                                                                                    descent:descent
                                                                                                      width:size.width];
    [self.attributedText replaceCharactersInRange:range withAttributedString:attachString];
}

- (void)vv_appendTextStorage:(VVTextStorage *)aTextStorage {
    if (!aTextStorage) {
        return;
    }

    NSMutableAttributedString *attributedString = [aTextStorage attributedText];
    if (!attributedString) {
        return;
    }

    [self.attributedText appendAttributedString:attributedString];
}

#pragma mark - Setter

- (void)setText:(NSString *)text {
    if (!text || _text == text) {
        return;
    }
    _text = [text copy];

    _attributedText = [[NSMutableAttributedString alloc] initWithString:_text attributes:nil];
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [_attributedText setTextColor:self.textColor range:range];
    [_attributedText setTextBackgroundColor:self.textBackgroundColor range:range];
    [_attributedText setFont:self.font range:range];
    [_attributedText setCharacterSpacing:self.characterSpacing range:range];
    [_attributedText setUnderlineStyle:self.underlineStyle underlineColor:self.underlineColor range:range];
    [_attributedText vv_setTextAlignment:self.textAlignment range:range];
    [_attributedText vv_setLineSpacing:self.linespacing range:range];
    [_attributedText vv_setLineBreakMode:self.lineBreakMode range:range];
}

- (void)setTextDrawMode:(VVTextDrawMode)textDrawMode {
    if (_textDrawMode != textDrawMode) {
        _textDrawMode = textDrawMode;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    if (self.textDrawMode == VVTextDrawModeStroke) {
        [_attributedText setStrokeColor:self.strokeColor strokeWidth:self.strokeWidth range:range];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    if (_strokeColor != strokeColor) {
        _strokeColor = strokeColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    if (self.textDrawMode == VVTextDrawModeStroke) {
        [_attributedText setStrokeColor:self.strokeColor strokeWidth:self.strokeWidth range:range];
    }
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    if (_strokeWidth != strokeWidth) {
        _strokeWidth = strokeWidth;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    if (self.textDrawMode == VVTextDrawModeStroke) {
        [_attributedText setStrokeColor:self.strokeColor strokeWidth:self.strokeWidth range:range];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setTextColor:self.textColor range:range];
}

- (void)setTextBackgroundColor:(UIColor *)textBackgroundColor {
    if (_textBackgroundColor != textBackgroundColor) {
        _textBackgroundColor = textBackgroundColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setTextBackgroundColor:self.textBackgroundColor range:range];
}

- (void)setTextBoundingStrokeColor:(UIColor *)textBoundingStrokeColor {
    if (_textBoundingStrokeColor != textBoundingStrokeColor) {
        _textBoundingStrokeColor = textBoundingStrokeColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setTextBoundingStrokeColor:self.textBoundingStrokeColor range:range];
}

- (void)setFont:(UIFont *)font {
    if (_font != font) {
        _font = font;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setFont:self.font range:range];
}

- (void)setCharacterSpacing:(unichar)characterSpacing {
    if (_characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setCharacterSpacing:self.characterSpacing range:range];
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    if (_underlineStyle != underlineStyle) {
        _underlineStyle = underlineStyle;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setUnderlineStyle:self.underlineStyle
                            underlineColor:self.underlineColor
                                     range:range];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText vv_setTextAlignment:self.textAlignment range:range];
}

- (void)setLinespacing:(CGFloat)linespacing {
    if (_linespacing != linespacing) {
        _linespacing = linespacing;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText vv_setLineSpacing:self.linespacing range:range];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText vv_setLineBreakMode:self.lineBreakMode range:range];
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    _position = _frame.origin;
}

- (void)setMaxNumberOfLine:(NSInteger)maxNumberOfLine {
    _maxNumberOfLines = maxNumberOfLine;
}

- (void)setNeedDebug:(BOOL)needDebug {
    _needDebug = needDebug;
}

- (void)setVericalAlignment:(VVTextVericalAlignment)vericalAlignment {
    _vericalAlignment = vericalAlignment;
}

- (void)vv_Layout {
    if (!self.attributedText) {
        return;
    }

    VVTextContainer *textContainer = [VVTextContainer vv_textContainerWithSize:self.frame.size];
    textContainer.maxNumberOfLines = self.maxNumberOfLines;
    textContainer.vericalAlignment = self.vericalAlignment;
    self.textLayout = [VVTextLayout vv_layoutWithContainer:textContainer text:self.attributedText];
    self.textLayout.needDebugDraw = self.needDebug;
}

#pragma mark - Getter

- (BOOL)isTruncation {
    return self.textLayout.needTruncation;
}

- (NSInteger)numberOfLines {
    return self.textLayout.numberOfLines;
}

- (CGFloat)left {
    return self.textLayout.cgPathBox.origin.x + self.position.x;
}

- (CGFloat)right {
    return self.textLayout.cgPathBox.origin.x + self.position.x + self.width;
}

- (CGFloat)top {
    return self.textLayout.cgPathBox.origin.y + self.position.y;
}

- (CGFloat)bottom {
    return self.textLayout.cgPathBox.origin.y + self.position.y + self.height;
}

- (CGFloat)height {
    return self.textLayout.suggestSize.height;
}

- (CGFloat)width {
    return self.textLayout.suggestSize.width;
}

- (void)setCenter:(CGPoint)center {
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width * 0.5f;
    frame.origin.y = center.y - frame.size.height * 0.5f;
    self.frame = frame;
}

- (CGPoint)center {
    return CGPointMake(self.textLayout.cgPathBox.origin.x + self.position.x + self.textLayout.cgPathBox.size.width * 0.5f,
            self.textLayout.cgPathBox.origin.y + self.position.y + self.textLayout.cgPathBox.size.height * 0.5f);
}

- (CGSize)suggestSize {
    return self.textLayout.suggestSize;
}

- (NSString *)text {
    return self.attributedText.string;
}

@end
