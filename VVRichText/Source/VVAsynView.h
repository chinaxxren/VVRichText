
#import <UIKit/UIKit.h>

#import "VVRichTextUtils.h"
#import "VVWidgetStore.h"
#import "VVRichTextDefine.h"

@class VVAsynLayer;
@class VVAsynView;
@class VVTextWidget;
@class VVImageWidget;
@class VVImageView;

@protocol VVAsyncViewDelegate <NSObject>

@optional

/**
 *  通过VVTextWidget的“- (void)vv_addLinkForWholeTextWidgetWithData:(id)data linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor;”方法添加的文字链接，点击时可以在这个代理方法里收到回调。
 *
 *  @param asynView VVTextWidget所处的VVAsyncView
 *  @param textWidget      点击的那个VVTextWidget对象
 *  @param data             添加点击链接时所附带的信息。
 */
- (void)vv_asynView:(VVAsynView *)asynView didCilickedTextWidget:(VVTextWidget *)textWidget linkdata:(id)data;

/**
 *  通过VVTextWidget添加的文字长按事件，长按时可以在这个代理方法里收到回调。
 *
 *  @param asynView VVTextWidget所处的VVAsyncView
 *  @param textWidget      点击的那个VVTextWidget对象
 *  @param data             添加点击链接时所附带的信息。
 */
- (void)vv_asynView:(VVAsynView *)asynView didLongpressedTextWidget:(VVTextWidget *)textWidget linkdata:(id)data;


/**
 *  点击VVImageWidget时，可以在这个代理方法里收到回调
 *
 *  @param asynView VVImageWidget所处的VVAsyncView
 *  @param imageWidget     点击的那个VVImageWidget对象
 *  @param touch            点击事件的UITouch对象
 */
- (void)vv_asynView:(VVAsynView *)asynView didCilickedImageWidget:(VVImageWidget *)imageWidget touch:(UITouch *)touch;

/**
 *  可以在这个代理方法里完成额外的绘制任务，相当于UIView的“drawRect:”方法。但是在这里绘制任务的都是在子线程完成的。
 *
 *  @param context     CGContextRef对象
 *  @param size        绘制空间的大小，需要在这个size的范围内绘制
 *  @param isCancelled 是否取消
 */
- (void)vv_extraAsyncIncontext:(CGContextRef)context size:(CGSize)size isCancelled:(VVAsyncIsCanclledBlock)isCancelled;

@end

/**
 *  在使用VVHTMLView时，因为解析HTML取得图片时，并不知道图片的大小比例，这个回调用于获取下载完图片后调整UIView的大小。
 *
 *  @param imageWidget VVImageWidget对象
 *  @param delta        下载完的图片高度与预填充图片高度的差
 */
typedef void(^VVAsyncViewLayoutCallback)(VVImageWidget *imageWidget, CGFloat delta);


@interface VVAsynView : UIView

@property(nonatomic, strong) id <VVWidgetStoreProtocol> layout; //布局模型,需要遵循VVLayoutProtocol协议
@property(nonatomic, weak) id <VVAsyncViewDelegate> delegate; //代理对象
@property(nonatomic, assign) BOOL asynDisplay; //是否异步绘制，默认是YES
@property(nonatomic, assign) BOOL imageLevel; //是否支持图片层级显示
@property(nonatomic, copy) VVAsyncViewLayoutCallback layoutCallback; //自动布局回调Block
@property(nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture; //长按手势

/**
 *  移除高亮显示
 *
 */
- (void)vv_removeHighlightIfNeed;

@end
