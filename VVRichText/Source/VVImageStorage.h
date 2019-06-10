
#import <UIKit/UIKit.h>

#import "VVStorage.h"
#import "VVRichTextDefine.h"

/**
 *  如果是本地图片，可以选择是直接绘制在VVAsyncDisplayView上还是新建一个VVAsyncImageView并add到VVAsyncDisplayView上
 */
typedef NS_ENUM(NSUInteger, VVLocalImageType) {
    VVLocalImageDrawInVVAsyncDisplayView, // 直接绘制在VVAsyncDisplayView上
    VVLocalImageTypeDrawInVVAsyncImageView, // 绘制在VVAsyncImageView上
};


/**
 *   图片绘制的数据模型
 */
@interface VVImageStorage : VVStorage

@property(nonatomic, strong) id contents;//内容（UIImage or NSURL）
@property(nonatomic, assign) VVLocalImageType localImageType;//本地图片的种类，默认是VVLocalImageDrawInVVAsyncDisplayView
@property(nonatomic, strong) UIImage *placeholder;//占位图
@property(nonatomic, assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;//是否响应用户事件，默认是YES
@property(nonatomic, assign, readonly) BOOL needRerendering;//是否需要重新绘制
@property(nonatomic, assign) BOOL needResize;//是否需要重新设置大小,不要去设置这个值，这个用于VVHTMLDisplayView重新调整图片大小比例
@property(nonatomic, assign) BOOL isBlur;//是否模糊处理

/**
 *  绘制图片
 *
 *  @param context    一个CGContextRef对象，绘制上下文
 *  @param isCancelld 是否取消绘制
 */
- (void)vv_drawInContext:(CGContextRef)context isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelld;

/**
 *  伸缩绘制
 *
 *  @param leftCapWidth 图片左边伸缩点
 *  @param topCapHeight 图片的上边伸缩点
 */
- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end

