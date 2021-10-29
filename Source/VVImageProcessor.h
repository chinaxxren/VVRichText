
#import <UIKit/UIKit.h>

@interface VVImageProcessor : NSObject

+ (UIImage *)vv_processImage:(UIImage *)img
                        size:(CGSize)size
                 borderWidth:(CGFloat)borderWidth
       cornerBackgroundColor:(UIColor *)cornerBackgroundColor
                 borderColor:(UIColor *)borderColor
                        blur:(BOOL)blur
                 contentMode:(UIViewContentMode)contentMode
                cornerRadius:(CGFloat)cornerRadius;
@end
