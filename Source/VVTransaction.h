

#import <Foundation/Foundation.h>
#import "VVRichTextUtils.h"


@class VVTransaction;

typedef void(^VVAsyncTransactionCompletionBlock)(VVTransaction *completeTransaction, BOOL isCancelled);

typedef void(^VVAsyncTransactionOperationCompletionBlock)(BOOL canceled);

/**
 *  VVAsyncTransaction事务的状态
 */
typedef NS_ENUM(NSUInteger, VVAsyncTransactionState) {
    VVAsyncTransactionStateOpen = 0, //开始处理一个事务
    VVAsyncTransactionStateCommitted, //提交一个事务
    VVAsyncTransactionStateCanceled, //事务取消
    VVAsyncTransactionStateComplete // 事务完成
};


/**
 * VVTransaction封装了一个消息的接收者target、selecotr、和一个参数object
 */
@interface VVTransaction : NSObject


/**
 *  构造方法
 *
 *  @param callbackQueue   事务处理完成后会收到回调，这里可以指定回调所在的dispatch_queue_t
 *  @param completionBlock 事务处理完成回调Block
 *
 *  @return 一个VVTransaction对象
 */
- (VVTransaction *)initWithCallbackQueue:(dispatch_queue_t)callbackQueue
                         completionBlock:(VVAsyncTransactionCompletionBlock)completionBlock;

@property(nonatomic, strong, readonly) dispatch_queue_t callbackQueue;//回调所在的dispatch_queue_t
@property(nonatomic, copy, readonly) VVAsyncTransactionCompletionBlock completionBlock;//处理完成时回调的Block
@property(nonatomic, assign, readonly) VVAsyncTransactionState state;//事务状态


/**
 *  添加一个操作到VVTransaction
 *
 *  @param target             消息接收者
 *  @param selector           消息选择子
 *  @param object             消息参数
 *  @param operationComletion 操作完成回调
 */
- (void)addAsyncOperationWithTarget:(id)target
                           selector:(SEL)selector
                             object:(id)object
                         completion:(VVAsyncTransactionOperationCompletionBlock)operationComletion;

/**
 *  提交一个VVTransaction中的Operation
 */
- (void)commit;

/**
 *  取消一个VVTransaction当中的Operation
 */
- (void)cancel;

@end

