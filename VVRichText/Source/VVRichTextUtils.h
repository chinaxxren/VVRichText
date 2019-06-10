
#import <UIKit/UIKit.h>


@interface VVRichTextUtils : NSObject

/**
 *  获取当前屏幕的contentScale
 *
 *  @return [UIScreen mainScreen].contentsScale
 */
+ (CGFloat)contentsScale;


/**
 *  获取UIView的截图
 *
 *  @param aView 一个UIView对象
 *
 *  @return 截图的UIImage
 */
+ (UIImage *)screenshotFromView:(UIView *)aView;

/**
 *  求两个数的最大公约数
 *
 *  @param aView 一个UIView对象
 *
 *  @return 最大公约数
 */
+ (NSUInteger)greatestCommonDivisorWithNumber:(NSUInteger)numb1 another:(NSUInteger)numb2;


@end

