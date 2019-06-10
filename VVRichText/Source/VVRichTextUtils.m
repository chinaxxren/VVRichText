
#import "VVRichTextUtils.h"

@implementation VVRichTextUtils

+ (CGFloat)contentsScale {
    static dispatch_once_t once;
    static CGFloat contentsScale;
    dispatch_once(&once, ^{
        contentsScale = [UIScreen mainScreen].scale;
    });
    return contentsScale;
}


+ (UIImage *)screenshotFromView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size, NO, [UIScreen mainScreen].scale);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

/**
 *  求两个数的最大公约数
 *
 *  @param aView 一个UIView对象
 *
 *  @return 最大公约数
 */
+ (NSUInteger)greatestCommonDivisorWithNumber:(NSUInteger)a another:(NSUInteger)b {
    if (a < b) {
        return [self greatestCommonDivisorWithNumber:b another:a];
    } else if (a == b) {
        return b;
    }
    
    while (true) {
        NSUInteger remainder = a % b;
        if (remainder == 0) {
            return b;
        }
        a = b;
        b = remainder;
    }
}

@end



