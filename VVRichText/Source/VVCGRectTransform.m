
#import "VVCGRectTransform.h"

@implementation VVCGRectTransform

+ (CGRect)vv_CGRectFitWithContentMode:(UIViewContentMode)contentMode
                                 rect:(CGRect)rect
                                 size:(CGSize)siz {

    rect = CGRectStandardize(rect);
    siz.width = siz.width < 0 ? -siz.width : siz.width;
    siz.height = siz.height < 0 ? -siz.height : siz.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (contentMode) {
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01f || rect.size.height < 0.01f ||
                    siz.width < 0.01f || siz.height < 0.01f) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (contentMode == UIViewContentModeScaleAspectFit) {
                    if (siz.width / siz.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / siz.height;
                    } else {
                        scale = rect.size.width / siz.width;
                    }
                } else {
                    if (siz.width / siz.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / siz.width;
                    } else {
                        scale = rect.size.height / siz.height;
                    }
                }
                siz.width *= scale;
                siz.height *= scale;
                rect.size = siz;
                rect.origin = CGPointMake(center.x - siz.width * 0.5f, center.y - siz.height * 0.5f);
            }
        }
            break;
        case UIViewContentModeCenter: {
            rect.size = siz;
            rect.origin = CGPointMake(center.x - siz.width * 0.5f, center.y - siz.height * 0.5f);
        }
            break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - siz.width * 0.5f;
            rect.size = siz;
        }
            break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - siz.width * 0.5f;
            rect.origin.y += rect.size.height - siz.height;
            rect.size = siz;
        }
            break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - siz.height * 0.5f;
            rect.size = siz;
        }
            break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - siz.height * 0.5f;
            rect.origin.x += rect.size.width - siz.width;
            rect.size = siz;
        }
            break;
        case UIViewContentModeTopLeft: {
            rect.size = siz;
        }
            break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - siz.width;
            rect.size = siz;
        }
            break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - siz.height;
            rect.size = siz;
        }
            break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - siz.width;
            rect.origin.y += rect.size.height - siz.height;
            rect.size = siz;
        }
            break;
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }

    return rect;
}

@end
