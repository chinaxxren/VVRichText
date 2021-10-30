
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

/**
 *  求两个数的最大公约数
 *
 *  @return 最大公约数
 */
+ (NSUInteger)greatestCommonDivisorWithNumber:(NSUInteger)a another:(NSUInteger)b {
    if (a < b) {
        return [self greatestCommonDivisorWithNumber:b another:a];
    } else if (a == b) {
        return b;
    }

    while (YES) {
        NSUInteger remainder = a % b;
        if (remainder == 0) {
            return b;
        }
        a = b;
        b = remainder;
    }
}

@end



