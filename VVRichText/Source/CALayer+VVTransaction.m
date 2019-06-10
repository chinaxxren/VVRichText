
#import "CALayer+VVTransaction.h"

#import <objc/runtime.h>

#import "VVTransactionGroup.h"

static void *VVTransactionsKey = @"VVTransactionsKey";
static void *VVCurrentTransacitonKey = @"VVCurrentTransacitonKey";

@implementation CALayer (VVTransaction)

#pragma mark - Associations

- (void)setTransactions:(NSHashTable *)transactions {
    objc_setAssociatedObject(self, VVTransactionsKey, transactions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSHashTable *)transactions {
    return objc_getAssociatedObject(self, VVTransactionsKey);
}

- (void)setCurrentTransaction:(VVTransaction *)currentTransaction {
    objc_setAssociatedObject(self, VVCurrentTransacitonKey, currentTransaction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VVTransaction *)currentTransaction {
    return objc_getAssociatedObject(self, VVCurrentTransacitonKey);
}

- (VVTransactionContainerState)transactionContainerState {
    return ([self.transactions count] == 0) ? VVTransactionContainerStateNoTransactions : VVTransactionContainerStatePendingTransactions;
}

- (void)vv_transactionContainerWillBeginTransaction:(VVTransaction *)transaction {

}

- (void)vv_transactionContainerrDidCompleteTransaction:(VVTransaction *)transaction {

}

- (void)vv_cancelAsyncTransactions {
    VVTransaction *currentTransaction = self.currentTransaction;
    [currentTransaction commit];
    self.currentTransaction = nil;
    for (VVTransaction *transaction in [self.transactions copy]) {
        [transaction cancel];
    }
}

- (void)vv_asyncTransactionContainerStateDidChange {
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(vv_asyncTransactionContainerStateDidChange)]) {
        [delegate vv_asyncTransactionContainerStateDidChange];
    }
}

- (VVTransaction *)vv_asyncTransaction {
    VVTransaction *transaction = self.currentTransaction;
    if (transaction == nil) {
        NSHashTable *transactions = self.transactions;
        if (transactions == nil) {
            transactions = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
            self.transactions = transactions;
        }

        transaction = [[VVTransaction alloc] initWithCallbackQueue:dispatch_get_main_queue()
                                                   completionBlock:^(VVTransaction *completeTransaction, BOOL isCancelled) {
                                                       [transactions removeObject:completeTransaction];
                                                       [self vv_transactionContainerrDidCompleteTransaction:completeTransaction];
                                                       if ([transactions count] == 0) {
                                                           [self vv_asyncTransactionContainerStateDidChange];
                                                       }
                                                   }];
        [transactions addObject:transaction];
        self.currentTransaction = transaction;
        [self vv_transactionContainerWillBeginTransaction:transaction];
        if ([transactions count] == 1) {
            [self vv_asyncTransactionContainerStateDidChange];
        }
    }

    [[VVTransactionGroup mainTransactionGroup] addTransactionContainer:self];

    return transaction;
}

@end
