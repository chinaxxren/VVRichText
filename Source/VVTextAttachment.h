
#import <UIKit/UIKit.h>


extern NSString *const VVTextAttachmentAttributeName;
extern NSString *const VVTextLinkAttributedName;
extern NSString *const VVTextLongPressAttributedName;
extern NSString *const VVTextBackgroundColorAttributedName;
extern NSString *const VVTextStrokeAttributedName;
extern NSString *const VVTextBoundingStrokeAttributedName;

typedef NS_ENUM(NSUInteger, VVTextHighLightType) {
    VVTextHighLightTypeNormal,
    VVTextHighLightTypeWholeText,
    VVTextHighLightTypeLongPress,
};

/**
 *  文本的附件的封装，可以是图片或是UIView对象、CALayer对象
 */
@interface VVTextAttachment : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, strong) id content; //内容
@property(nonatomic, assign) NSRange range; //在string中的range
@property(nonatomic, assign) CGRect frame; //frame
@property(nonatomic, strong) NSURL *URL; //URL
@property(nonatomic, assign) UIViewContentMode contentMode; //内容模式
@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets; //边缘内嵌大小
@property(nonatomic, strong) NSDictionary *userInfo; //自定义的一些信息

/**
 *  构造方法
 *
 *  @param content 可以是UIImage对象、UIView对象、CALayer对象。
 *  如果是UIImage对象，会使用CoreGraphics方法来绘制
 *
 *  @return VVTextAttachment实例对象
 */
+ (instancetype)vv_textAttachmentWithContent:(id)content;

@end


/**
 *  文本链接的封装
 */
@interface VVTextHighlight : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, assign) NSRange range; //在字符串的range
@property(nonatomic, strong) UIColor *linkColor; //链接的颜色
@property(nonatomic, strong) UIColor *hightlightColor; //高亮颜色
@property(nonatomic, copy) NSArray<NSValue *> *positions; //位置数组
@property(nonatomic, strong) id content; //内容
@property(nonatomic, strong) NSDictionary *userInfo; //自定义的一些信息
@property(nonatomic, assign) VVTextHighLightType type; //高亮类型

@end


/**
 *  文本背景颜色的封装
 */
@interface VVTextBackgroundColor : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, assign) NSRange range; //在字符串的range
@property(nonatomic, strong) UIColor *backgroundColor; //背景颜色
@property(nonatomic, copy) NSArray<NSValue *> *positions; //位置数组
@property(nonatomic, strong) NSDictionary *userInfo; //自定义的一些信息

@end


/**
 *  文本描边的封装（空心字）
 */
@interface VVTextStroke : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, assign) NSRange range; //在字符串的range
@property(nonatomic, strong) UIColor *strokeColor; //描边颜色
@property(nonatomic, assign) CGFloat strokeWidth; //描边的宽度
@property(nonatomic, strong) NSDictionary *userInfo; //自定义的一些信息

@end

/**
 *  文本边框
 */
@interface VVTextBoundingStroke : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, assign) NSRange range; //在字符串的range
@property(nonatomic, strong) UIColor *strokeColor; //描边颜色
@property(nonatomic, copy) NSArray<NSValue *> *positions; //位置数组
@property(nonatomic, strong) NSDictionary *userInfo; //自定义的一些信息

@end

