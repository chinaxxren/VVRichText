
#import "VVTransaction.h"

#import <objc/message.h>

#import "VVTransactionGroup.h"

@interface VVAsyncDisplayTransactionOperation : NSObject

@property(nonatomic, strong) id target;
@property(nonatomic, assign) SEL selector;
@property(nonatomic, strong) id object;
@property(nonatomic, copy) VVAsyncTransactionOperationCompletionBlock completion;

- (id)initWithCompletion:(VVAsyncTransactionOperationCompletionBlock)completion;

- (void)callAndReleaseCompletionBlock:(BOOL)canceled;

@end

@implementation VVAsyncDisplayTransactionOperation

- (id)initWithCompletion:(VVAsyncTransactionOperationCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = [completion copy];
    }
    return self;
}

- (void)callAndReleaseCompletionBlock:(BOOL)canceled {
    void (*objc_msgSendToPerform)(id, SEL, id) = (void *) objc_msgSend;
    objc_msgSendToPerform(self.target, self.selector, self.object);
    if (self.completion) {
        self.completion(canceled);
        self.completion = nil;
    }
    self.target = nil;
    self.selector = nil;
    self.object = nil;
}

@end


@interface VVTransaction ()

@property(nonatomic, strong) dispatch_queue_t callbackQueue;
@property(nonatomic, copy) VVAsyncTransactionCompletionBlock completionBlock;
@property(nonatomic, assign) VVAsyncTransactionState state;
@property(nonatomic, strong) NSMutableArray *operations;

@end


@implementation VVTransaction

#pragma mark - LifeCycle

- (VVTransaction *)initWithCallbackQueue:(dispatch_queue_t)callbackQueue
                         completionBlock:(VVAsyncTransactionCompletionBlock)completionBlock {
    if ((self = [self init])) {
        if (callbackQueue == NULL) {
            callbackQueue = dispatch_get_main_queue();
        }
        self.callbackQueue = callbackQueue;
        self.completionBlock = [completionBlock copy];
        self.state = VVAsyncTransactionStateOpen;
    }
    return self;
}

#pragma mark - Methods

- (void)addAsyncOperationWithTarget:(id)target
                           selector:(SEL)selector
                             object:(id)object
                         completion:(VVAsyncTransactionOperationCompletionBlock)operationComletion {
    VVAsyncDisplayTransactionOperation *operation = [[VVAsyncDisplayTransactionOperation alloc]
            initWithCompletion:operationComletion];
    operation.target = target;
    operation.selector = selector;
    operation.object = object;
    [self.operations addObject:operation];
}

- (void)cancel {
    self.state = VVAsyncTransactionStateCanceled;
}

- (void)commit {
    self.state = VVAsyncTransactionStateCommitted;
    if ([_operations count] == 0) {
        if (_completionBlock) {
            _completionBlock(self, NO);
        }
    } else {
        [self completeTransaction];
    }
}

- (void)completeTransaction {
    if (_state != VVAsyncTransactionStateComplete) {
        BOOL isCanceled = (_state == VVAsyncTransactionStateCanceled);
        for (VVAsyncDisplayTransactionOperation *operation in self.operations) {
            [operation callAndReleaseCompletionBlock:isCanceled];
        }
        self.state = VVAsyncTransactionStateComplete;
        if (_completionBlock) {
            _completionBlock(self, isCanceled);
        }
    }
}

#pragma mark - Getter

- (NSMutableArray *)operations {
    if (_operations) {
        return _operations;
    }
    _operations = [[NSMutableArray alloc] init];
    return _operations;
}

@end



