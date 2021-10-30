
#import <UIKit/UIKit.h>

#import "VVWidget.h"
#import "VVRichTextDefine.h"

/**
 *  如果是本地图片，可以选择是直接绘制在VVAsyncView上还是新建一个VVAsyncImageView并add到VVAsyncView上
 */
typedef NS_ENUM(NSUInteger, VVLocalImageType) {
    VVLocalImageDrawInVVAsyncView, // 直接绘制在VVAsyncView上
    VVLocalImageTypeDrawInVVImageView, // 绘制在VVAsyncImageView上
};


/**
 *   图片绘制的数据模型
 */
@interface VVImageWidget : VVWidget

@property(nonatomic, strong) id contents;//内容（UIImage or NSURL）
@property(nonatomic, assign) VVLocalImageType localImageType;//本地图片的种类，默认是VVLocalImageDrawInVVAsyncView
@property(nonatomic, strong) UIImage *placeholder;//占位图
@property(nonatomic, assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;//是否响应用户事件，默认是YES
@property(nonatomic, assign, readonly) BOOL needRerendering;//是否需要重新绘制
@property(nonatomic, assign) BOOL needResize;//是否需要重新设置大小,不要去设置这个值，这个用于VVHTMLView重新调整图片大小比例
@property(nonatomic, assign) BOOL isBlur;//是否模糊处理
@property(nonatomic, assign) NSInteger level;//Image显示层级。在同区域时，只能是同时本地图片或者同时网络图片设置level有效，网络图片默认显示本地图片在层级之上

/**
 *  绘制图片
 *
 *  @param context    一个CGContextRef对象，绘制上下文
 *  @param isCancelld 是否取消绘制
 */
- (void)vv_drawInContext:(CGContextRef)context isCancelled:(VVAsyncIsCanclledBlock)isCancelld;

/**
 *  伸缩绘制
 *
 *  @param leftCapWidth 图片左边伸缩点
 *  @param topCapHeight 图片的上边伸缩点
 */
- (void)vv_stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end


