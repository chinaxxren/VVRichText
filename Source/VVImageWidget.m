
#import "VVImageWidget.h"

#import "UIImage+VVRichText.h"
#import "VVRichTextUtils.h"
#import "VVImage.h"

@interface VVImageWidget ()

@property(nonatomic, assign) BOOL needRerendering;

@end

@implementation VVImageWidget

@synthesize cornerRadius = _cornerRadius;
@synthesize cornerBorderWidth = _cornerBorderWidth;

#pragma mark - Override Hash & isEqual


- (BOOL)isEqual:(id)object {
    if (!object || ![object isMemberOfClass:[VVImageWidget class]]) {
        return NO;
    }
    if (self == object) {
        return YES;
    }

    VVImageWidget *imageWidget = (VVImageWidget *) object;
    return [imageWidget.contents isEqual:self.contents] && CGRectEqualToRect(imageWidget.frame, self.frame);
}


- (NSUInteger)hash {
    long v1 = (long) self.contents;
    long v2 = (long) [NSValue valueWithCGRect:self.frame];
    return v1 ^ v2;
}

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        self.contents = nil;
        self.userInteractionEnabled = YES;
        self.placeholder = nil;
        self.clipsToBounds = NO;
        self.contentsScale = [VVRichTextUtils contentsScale];
        self.needRerendering = NO;
        self.needResize = NO;
        self.localImageType = VVLocalImageDrawInVVAsyncView;
        self.isBlur = NO;
    }
    return self;
}

- (BOOL)needRerendering {
    // 这个图片设置了圆角的相关属性，需要对原图进行处理
    if (self.cornerBorderWidth != 0 || self.cornerRadius != 0) {
        return YES;
    } else {
        return _needRerendering;
    }
}

#pragma mark - Methods

- (void)vv_stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    if ([self.contents isKindOfClass:[UIImage class]] && self.localImageType == VVLocalImageDrawInVVAsyncView) {
        self.contents = [(UIImage *) self.contents resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, 0.0f, 0.0f) resizingMode:UIImageResizingModeStretch];
    }
}

- (void)vv_drawInContext:(CGContextRef)context isCancelled:(VVAsyncIsCanclledBlock)isCancelld {
    if (isCancelld()) {
        return;
    }

    if ([self.contents isKindOfClass:[NSURL class]]) {
        return;
    }

    if ([self.contents isKindOfClass:[UIImage class]] && self.localImageType == VVLocalImageDrawInVVAsyncView) {
        if ([self.contents isKindOfClass:[VVImage class]]) {
            VVImage *image = (VVImage *) self.contents;
            if (image.animatedImageType == YYImageTypeGIF) {
                return;
            }
        }

        UIImage *image = (UIImage *) self.contents;
        BOOL isOpaque = self.opaque;
        UIColor *backgroundColor = self.backgroundColor;
        CGFloat cornerRaiuds = self.cornerRadius;
        UIColor *cornerBackgroundColor = self.cornerBackgroundColor;
        UIColor *cornerBorderColor = self.cornerBorderColor;
        CGFloat cornerBorderWidth = self.cornerBorderWidth;
        CGRect rect = self.frame;
        rect = CGRectStandardize(rect);

        CGRect imgRect = {
                {rect.origin.x + cornerBorderWidth, rect.origin.y + cornerBorderWidth},
                {rect.size.width - 2.0f * cornerBorderWidth, rect.size.height - 2.0f * cornerBorderWidth}
        };

        if (!image) {
            return;
        }

        if (self.isBlur) {
            image = [image vv_applyBlurWithRadius:20.0f
                                        tintColor:[UIColor colorWithWhite:0.0f alpha:0.15f]
                            saturationDeltaFactor:1.4f
                                        maskImage:nil];
        }

        CGContextSaveGState(context);

        if (isOpaque && backgroundColor) {
            [backgroundColor setFill];
            UIRectFill(imgRect);
        }

        if (cornerBackgroundColor) {
            [cornerBackgroundColor setFill];
            UIBezierPath *backgroundRect = [UIBezierPath bezierPathWithRect:imgRect];
            [backgroundRect fill];
        }

        UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:imgRect cornerRadius:cornerRaiuds];
        [cornerPath addClip];

        [image vv_drawInRect:imgRect contentMode:self.contentMode clipsToBounds:YES];

        CGContextRestoreGState(context);

        if (cornerBorderColor && cornerBorderWidth != 0) {
            [cornerPath setLineWidth:cornerBorderWidth];
            [cornerBorderColor setStroke];
            [cornerPath stroke];
        }
    }
}


@end




