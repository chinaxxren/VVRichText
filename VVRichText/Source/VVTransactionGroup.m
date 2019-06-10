
#import "VVTransactionGroup.h"

#import "CALayer+VVTransaction.h"

static void _transactionGroupRunLoopObserverCallback(CFRunLoopObserverRef observer,
        CFRunLoopActivity activity,
        void *info);

@interface VVTransactionGroup ()

@property(nonatomic, strong) NSHashTable *layersContainers;

@end

@implementation VVTransactionGroup

#pragma mark - Init

+ (VVTransactionGroup *)mainTransactionGroup {
    static VVTransactionGroup *mainTransactionGroup;
    if (mainTransactionGroup == nil) {
        mainTransactionGroup = [[VVTransactionGroup alloc] init];
        [self registerTransactionGroupAsMainRunloopObserver:mainTransactionGroup];
    }
    return mainTransactionGroup;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.layersContainers = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
    }
    return self;
}

+ (void)registerTransactionGroupAsMainRunloopObserver:(VVTransactionGroup *)transactionGroup {
    static CFRunLoopObserverRef observer;
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFOptionFlags activities = (kCFRunLoopBeforeWaiting | kCFRunLoopExit);

    CFRunLoopObserverContext context = {
            0,
            (__bridge void *) transactionGroup,
            &CFRetain,
            &CFRelease,
            NULL
    };
    observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
            activities,
            YES,
            INT_MAX,
            &_transactionGroupRunLoopObserverCallback,
            &context);
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

#pragma mark - Methods

- (void)addTransactionContainer:(CALayer *)layerContainer {
    [self.layersContainers addObject:layerContainer];
}

+ (void)commit {
    [[VVTransactionGroup mainTransactionGroup] commit];
}

- (void)commit {
    if ([self.layersContainers count] == 0) {
        return;
    }
    
    NSHashTable *containerLayersToCommit = self.layersContainers;
    self.layersContainers = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
    for (CALayer *containerLayer in containerLayersToCommit) {
        VVTransaction *transaction = containerLayer.currentTransaction;
        containerLayer.currentTransaction = nil;
        [transaction commit];
    }
}

@end

static void _transactionGroupRunLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    VVTransactionGroup *group = (__bridge VVTransactionGroup *) info;
    [group commit];
}

