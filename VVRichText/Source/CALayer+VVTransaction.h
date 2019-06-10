
#import <UIKit/UIKit.h>
#import "VVTransaction.h"

/**
 *  这个扩展给CALayer添加一个哈希表，用来保存这个CALayer上的VVTransaction对象
 *
 */

typedef NS_ENUM(NSUInteger, VVTransactionContainerState) {
    VVTransactionContainerStateNoTransactions, // 没有操作需要处理
    VVTransactionContainerStatePendingTransactions, // 正在处理操作
};


@protocol VVTransactionContainerDelegate

@property(nonatomic, readonly, assign) VVTransactionContainerState transactionContainerState; //操作事务容器的状态

/**
 *  取消这个容器CALayer上的所有事务,如果这个事务已经在执行了，则执行完
 */
- (void)vv_cancelAsyncTransactions;

/**
 *  操作事务容器的状态改变时回调
 */
- (void)vv_asyncTransactionContainerStateDidChange;

@end


/**
 *  VVTransaction对象是通过runloop的observer观察到退出一个runloop和runloop即将进入休眠时
 *  需要执行的操作的抽象。这是VVTransaction对CALayer的扩展
 */
@interface CALayer (VVTransaction) <VVTransactionContainerDelegate>

//这个CALayer对象上的操作事务哈希表
@property(nonatomic, strong) NSHashTable *transactions;

//当前正在处理的事务
@property(nonatomic, strong) VVTransaction *currentTransaction;

//创建一个VVTransaction并添加到transactions当中
@property(nonatomic, readonly, strong) VVTransaction *vv_asyncTransaction;

//即将要开始处理一个VVTransaction
- (void)vv_transactionContainerWillBeginTransaction:(VVTransaction *)transaction;

//VVTransaction处理完成
- (void)vv_transactionContainerrDidCompleteTransaction:(VVTransaction *)transaction;


@end
