

#import <UIKit/UIKit.h>

#import "VVTransaction.h"

/**
 *  这个类用于管理所有transactions<VVTransaction *>容器不为空的CALayer对象
 *  VVTransactionGroup把这些CALayer对象放在一个哈希表layersContainers中
 *  VVTransactionGroup注册了一个主线程的runLoopObserver，当状态为(kCFRunLoopBeforeWaiting | kCFRunLoopExit)时，
 *  VVTransactionGroup会遍历layersContainers，来对这些CALayer上的所有VVTransactions执行 commit
 */
@interface VVTransactionGroup : NSObject

/**
 *  获取主线程CFRunLoopObserverRef，注册观察时间点并返回封装后的VVTransactionGroup对象
 *
 *  @return 一个VVTransactionGroup对象
 */
+ (VVTransactionGroup *)mainTransactionGroup;

/**
 *  将一个包含VVTransaction事物的CALayer添加到VVTransactionGroup
 *
 *  @param containerLayer CALayer容器
 */
- (void)addTransactionContainer:(CALayer *)containerLayer;

/**
 *  提交mainTransactionGroup当中所有容器中的所有任务的操作
 *
 */
+ (void)commit;

@end
