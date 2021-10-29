
#import <UIKit/UIKit.h>
#import "VVIdentifier.h"

/**
 *  包含各种布局数据和其他数据的抽象模型，本身并不能直接拿来使用。
 *  它的子类VVTextWidget、VVImageWidget、VVVideoWidget可以分别用于存储文字、图片。
 */
NS_ASSUME_NONNULL_BEGIN

@interface VVWidget : VVIdentifier

@property(nonatomic, assign) NSInteger tag;//一个标示符，跟UIView对象的tag属性作用一样
@property(nonatomic, assign) BOOL clipsToBounds;//是否在边缘剪切，跟UIView对象的clipsToBounds属性作用一样
@property(nonatomic, getter = isOpaque) BOOL opaque;//跟UIView对象的同名属性作用一样
@property(nonatomic, getter = isHidden) BOOL hidden;//跟UIView对象的同名属性作用一样
@property(nonatomic, assign) CGFloat alpha;//跟UIView对象的同名属性作用一样
@property(nonatomic, assign) CGRect frame;//跟UIView对象的同名属性作用一样
@property(nonatomic, assign) CGRect bounds;//跟UIView对象的同名属性作用一样


@property(nonatomic, assign, readonly) CGFloat height;//跟UIView对象的frame.size.height作用一样
@property(nonatomic, assign, readonly) CGFloat width;//跟UIView对象的frame.size.width作用一样
@property(nonatomic, assign, readonly) CGFloat left;//跟UIView对象的frame.origin.x作用一样
@property(nonatomic, assign, readonly) CGFloat right;//跟UIView对象的frame.origin.x+frame.size.width作用一样
@property(nonatomic, assign, readonly) CGFloat top;//跟UIView对象的frame.origin.y作用一样
@property(nonatomic, assign, readonly) CGFloat bottom;//跟UIView对象的frame.origin.y+frame.size.height作用一样


@property(nonatomic, assign) CGPoint center;//跟UIView对象的同名属性作用一样
@property(nonatomic, assign) CGPoint position;//跟UIView对象的同名属性作用一样
@property(nonatomic, assign) CGFloat cornerRadius;//跟CALayer对象的同名属性作用一样
@property(nonatomic, strong) UIColor *cornerBackgroundColor;//圆角半径部分的背景颜色
@property(nonatomic, strong) UIColor *cornerBorderColor;//圆角半径的描边颜色
@property(nonatomic, assign) CGFloat cornerBorderWidth;//圆角半径的描边宽度
@property(nonatomic, assign) UIColor *shadowColor;//跟CALayer对象的同名属性作用一样
@property(nonatomic, assign) CGFloat shadowOpacity;//跟CALayer对象的同名属性作用一样
@property(nonatomic, assign) CGSize shadowOffset;//跟CALayer对象的同名属性作用一样
@property(nonatomic, assign) CGFloat shadowRadius;//跟CALayer对象的同名属性作用一样
@property(nonatomic, assign) CGFloat contentsScale;//跟CALayer对象的同名属性作用一样
@property(nonatomic, strong) UIColor *backgroundColor;//跟UIView对象的同名属性作用一样
@property(nonatomic, assign) UIViewContentMode contentMode;//跟UIView对象的同名属性作用一样

/**
 *  设置一个标示字符串并初始化一个VVWidget对象
 *
 *  @param identifier 一个标示字符串
 *
 *  @return 一个VVWidget对象
 */
- (instancetype)initWithIdentifier:(NSString *_Nullable)identifier;

@end

NS_ASSUME_NONNULL_END
