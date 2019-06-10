
#import "VVImageProcessor.h"
#import "VVRichTextUtils.h"
#import "VVRichTextDefine.h"
#import "UIImage+VVRichText.h"


@implementation VVImageProcessor

+ (UIImage *)vv_processImage:(UIImage *)img
                        size:(CGSize)size
                 borderWidth:(CGFloat)borderWidth
       cornerBackgroundColor:(UIColor *)cornerBackgroundColor
                 borderColor:(UIColor *)borderColor
                        blur:(BOOL)blur
                 contentMode:(UIViewContentMode)contentMode
                cornerRadius:(CGFloat)cornerRadius {
    if (size.width < 0 || size.height < 0) {
        return nil;
    }
    CGFloat width = size.width * [VVRichTextUtils contentsScale];
    CGFloat height = size.height * [VVRichTextUtils contentsScale];
    cornerRadius = cornerRadius * [VVRichTextUtils contentsScale];
    borderWidth = borderWidth * [VVRichTextUtils contentsScale];

    UIImage *processedImg = [img vv_processedImageWithContentMode:contentMode size:CGSizeMake(width, height)];
    if (blur) {
        processedImg = [processedImg vv_applyBlurWithRadius:20
                                                  tintColor:RGB(0, 0, 0, 0.15f)
                                      saturationDeltaFactor:1.4
                                                  maskImage:nil];
    }


    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, (size_t) width, (size_t) height, 8, 4 * (size_t) width,
            colorSpace,
            kCGImageAlphaPremultipliedFirst);
    CGRect rect = {{0, 0}, {width, height}};

    CGRect imgRect = {{borderWidth, borderWidth}, {width - 2 * borderWidth, height - 2 * borderWidth}};

    if (cornerBackgroundColor) {
        CGContextSaveGState(context);
        CGContextAddRect(context, rect);
        CGContextSetFillColorWithColor(context, cornerBackgroundColor.CGColor);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }

    {
        CGContextSaveGState(context);
        if (cornerRadius) {
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:imgRect
                                                                  cornerRadius:cornerRadius];
            CGContextAddPath(context, bezierPath.CGPath);
            CGContextClip(context);
        }
        CGContextDrawImage(context, imgRect, processedImg.CGImage);
        CGContextRestoreGState(context);
    }

    if (borderColor && borderWidth != 0) {
        CGContextSaveGState(context);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:imgRect
                                                              cornerRadius:cornerRadius];
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, borderWidth);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }

    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    UIImage *results = [UIImage imageWithCGImage:imageMasked];

    CGImageRelease(imageMasked);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    return results;
}

@end
