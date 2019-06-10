
#import <UIKit/UIKit.h>
#import "VVRichTextDefine.h"


@class VVFlag;
@protocol VVAsyncDisplayLayerDelegate;


@interface VVAsyncDisplayLayer : CALayer

@property(nonatomic, assign) BOOL displaysAsynchronously;//是否异步绘制，默认是YES
@property(nonatomic, strong, readonly) VVFlag *displayFlag;//一个自增的标识类，用于取消绘制。


/**
 *  立即绘制，在主线程
 */
- (void)displayImmediately;

/**
 *  取消异步绘制
 */
- (void)cancelAsyncDisplay;

/**
 *  VVAsyncDisplayLayer异步绘制时都会指定一个dispatch_queue_t，这个方法可以获取那个dispatch_queue_t
 *
 *  @return  VVAsyncDisplayLayer对象异步绘制所在的那个dispatch_queue_t
 */
+ (dispatch_queue_t)displayQueue;

@end

/**
 *  异步绘制任务的抽象，它包含的属性是三个Block可以分别在将要开始绘制时，绘制时，和绘制完成时都收到回调。
 */
@interface VVAsyncDisplayTransaction : NSObject

@property(nonatomic, copy) VVAsyncDisplayWillDisplayBlock willDisplayBlock;//即将要开始绘制
@property(nonatomic, copy) VVAsyncDisplayBlock displayBlock;//绘制的具体实现
@property(nonatomic, copy) VVAsyncDisplayDidDisplayBlock didDisplayBlock;//绘制已经完成

@end


@protocol VVAsyncDisplayLayerDelegate <NSObject>

/**
 *  异步绘制协议的协议方法
 *  @return 返回一个异步绘制任务的抽象VVAsyncDisplayTransaction对象，可以通过这个对象的属性来得到将要开始绘制时，绘制时，和绘制完成时的回调。
 */
- (VVAsyncDisplayTransaction *)asyncDisplayTransaction;

@end



