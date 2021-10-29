

#import <UIKit/UIKit.h>


@interface VVCGRectTransform : NSObject

/**
 *  根据contentMode获取绘制的CGRect
 *
 */
+ (CGRect)vv_CGRectFitWithContentMode:(UIViewContentMode)contentMode
                                 rect:(CGRect)rect
                                 size:(CGSize)siz;

@end
