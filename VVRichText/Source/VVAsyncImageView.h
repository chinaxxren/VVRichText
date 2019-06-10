
#import <UIKit/UIKit.h>
#import <YYImage/YYAnimatedImageView.h>


@class VVImageStorage;

@interface VVAsyncImageView : YYAnimatedImageView

/**
 *  一个标示符字符串，跟VVImageStorage中的同名属性对应.
 *  当VVAsyncImageView不需要时，会放入VVAsyncDisplayView的reusePool当中
 *  需要用到时，通过这个identifier为key去reusePool中取
 */
@property(nonatomic, copy) NSString *identifier;


/**
 *  是否启动异步绘制
 *  YES时，会把对layer.conents，setFrame等赋值任务加入到VVTransactionGroup队列中
 *  然后通过观察主线程RunLoop的状态为 kCFRunLoopBeforeWaiting | kCFRunLoopExit 时才执行
 */
@property(nonatomic, assign) BOOL displayAsynchronously;

@end
