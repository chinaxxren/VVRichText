
#import <UIKit/UIKit.h>

#import "VVRichTextUtils.h"
#import "VVLayout.h"
#import "VVRichTextDefine.h"

@class VVAsynLayer;
@class VVAsynView;
@class VVTextStorage;
@class VVImageStorage;
@class VVImageView;

@protocol VVAsyncDisplayViewDelegate <NSObject>

@optional

/**
 *  通过VVTextStorage的“- (void)vv_addLinkForWholeTextStorageWithData:(id)data linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor;”方法添加的文字链接，点击时可以在这个代理方法里收到回调。
 *
 *  @param asyncDisplayView VVTextStorage所处的VVAsyncDisplayView
 *  @param textStorage      点击的那个VVTextStorage对象
 *  @param data             添加点击链接时所附带的信息。
 */
- (void)vv_asyncDisplayView:(VVAsynView *)asyncDisplayView didCilickedTextStorage:(VVTextStorage *)textStorage linkdata:(id)data;

/**
 *  通过VVTextStorage添加的文字长按事件，长按时可以在这个代理方法里收到回调。
 *
 *  @param asyncDisplayView VVTextStorage所处的VVAsyncDisplayView
 *  @param textStorage      点击的那个VVTextStorage对象
 *  @param data             添加点击链接时所附带的信息。
 */
- (void)vv_asyncDisplayView:(VVAsynView *)asyncDisplayView didLongpressedTextStorage:(VVTextStorage *)textStorage linkdata:(id)data;


/**
 *  点击VVImageStorage时，可以在这个代理方法里收到回调
 *
 *  @param asyncDisplayView VVImageStorage所处的VVAsyncDisplayView
 *  @param imageStorage     点击的那个VVImageStorage对象
 *  @param touch            点击事件的UITouch对象
 */
- (void)vv_asyncDisplayView:(VVAsynView *)asyncDisplayView didCilickedImageStorage:(VVImageStorage *)imageStorage touch:(UITouch *)touch;

/**
 *  可以在这个代理方法里完成额外的绘制任务，相当于UIView的“drawRect:”方法。但是在这里绘制任务的都是在子线程完成的。
 *
 *  @param context     CGContextRef对象
 *  @param size        绘制空间的大小，需要在这个size的范围内绘制
 *  @param isCancelled 是否取消
 */
- (void)vv_extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size isCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelled;

@end

/**
 *  在使用VVHTMLView时，因为解析HTML取得图片时，并不知道图片的大小比例，这个回调用于获取下载完图片后调整UIView的大小。
 *
 *  @param imageStorage VVImageStorage对象
 *  @param delta        下载完的图片高度与预填充图片高度的差
 */
typedef void(^VVAsyncDisplayViewAutoLayoutCallback)(VVImageStorage *imageStorage, CGFloat delta);


@interface VVAsynView : UIView

@property(nonatomic, strong) id <VVLayoutProtocol> layout; //布局模型,需要遵循VVLayoutProtocol协议
@property(nonatomic, weak) id <VVAsyncDisplayViewDelegate> delegate; //代理对象
@property(nonatomic, assign) BOOL displaysAsynchronously; //是否异步绘制，默认是YES
@property(nonatomic, assign) BOOL imageLevel; //是否支持图片层级显示
@property(nonatomic, copy) VVAsyncDisplayViewAutoLayoutCallback auotoLayoutCallback; //自动布局回调Block
@property(nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture; //长按手势

/**
 *  移除高亮显示
 *
 */
- (void)vv_removeHighlightIfNeed;

@end
