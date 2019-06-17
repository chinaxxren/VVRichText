
#import "VVAsynLayer.h"

#import <libkern/OSAtomic.h>

#import "VVTransactionGroup.h"
#import "CALayer+VVTransaction.h"
#import "VVFlag.h"

@interface VVAsynLayer ()

@property(nonatomic, strong) VVFlag *displayFlag;

@end


@implementation VVAsynLayer


#pragma mark -

+ (dispatch_queue_t)displayQueue {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int) [NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        for (NSUInteger i = 0; i < queueCount; i++) {
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
            queues[i] = dispatch_queue_create("com.VVRichText.VVAsynLayer.displayQueue", attr);
        }
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    uint32_t cur = (uint32_t) OSAtomicIncrement32(&counter);
#pragma clang diagnostic pop
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}

+ (dispatch_queue_t)releaseQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"displaysAsynchronously"]) {
        return @YES;
    } else {
        return [super defaultValueForKey:key];
    }
}

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        _displayFlag = [[VVFlag alloc] init];
        self.opaque = YES;
        self.displaysAsynchronously = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _displayFlag = [[VVFlag alloc] init];
        self.opaque = YES;
        self.displaysAsynchronously = YES;
    }
    return self;
}

- (void)setNeedsDisplay {
    [self cancelAsyncDisplay];

    [super setNeedsDisplay];
}

- (void)display {
    [self _hackResetNeedsDisplay];
    [self display:self.displaysAsynchronously];
}

- (void)_hackResetNeedsDisplay {
    super.contents = super.contents;
}

- (void)displayImmediately {
    [_displayFlag increment];
    [self display:NO];
}

- (void)dealloc {
    [self.displayFlag increment];
}

#pragma mark - Display


- (void)display:(BOOL)asynchronously {
    __strong id <VVAsyncDisplayLayerDelegate> delegate = (id) self.delegate;
    VVAsyncDisplayTransaction *transaction = [delegate asyncDisplayTransaction];
    if (!transaction.displayBlock) {
        if (transaction.willDisplayBlock) {
            transaction.willDisplayBlock(self);
        }

        CGImageRef imageRef = (__bridge_retained CGImageRef) (self.contents);
        id contents = self.contents;
        self.contents = nil;
        if (imageRef) {
            dispatch_async([VVAsynLayer releaseQueue], ^{
                [contents class];
                CFRelease(imageRef);
            });
        }

        if (transaction.didDisplayBlock) {
            transaction.didDisplayBlock(self, YES);
        }
        return;
    }

    //清除之前的内容
    CGImageRef imageRef = (__bridge_retained CGImageRef) (self.contents);
    id contents = self.contents;
    self.contents = nil;
    if (imageRef) {
        dispatch_async([VVAsynLayer releaseQueue], ^{
            [contents class];
            CFRelease(imageRef);
        });
    }

    CGSize size = self.bounds.size;

    // 把内容尽可能多的绘制在同一个CALayer上，然后赋值给contents
    if (asynchronously) {
        if (transaction.willDisplayBlock) {
            transaction.willDisplayBlock(self);
        }

        VVFlag *displayFlag = _displayFlag;
        int32_t value = displayFlag.value;

        VVAsyncDisplayIsCanclledBlock isCancelledBlock = ^BOOL() {
            return value != displayFlag.value;
        };

        BOOL opaque = self.opaque;
        CGFloat scale = self.contentsScale;
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;

        if (size.width < 1.0f || size.height < 1.0f) {
            CGImageRef image = (__bridge_retained CGImageRef) (self.contents);
            self.contents = nil;
            if (image) {
                dispatch_async([VVAsynLayer displayQueue], ^{
                    CFRelease(image);
                });
            }
            if (transaction.didDisplayBlock) {
                transaction.didDisplayBlock(self, YES);
            }
            CGColorRelease(backgroundColor);
            return;
        }

        dispatch_async([VVAsynLayer displayQueue], ^{
            if (isCancelledBlock()) {
                CGColorRelease(backgroundColor);
                return;
            }

            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (opaque) {
                CGContextSaveGState(context);
                {
                    if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                        CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                        CGContextFillPath(context);
                    }
                    if (backgroundColor) {
                        CGContextSetFillColorWithColor(context, backgroundColor);
                        CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                        CGContextFillPath(context);
                    }
                }
                CGContextRestoreGState(context);
                CGColorRelease(backgroundColor);
            }
            transaction.displayBlock(self, context, size, isCancelledBlock);
            if (isCancelledBlock()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (transaction.didDisplayBlock) {
                        transaction.didDisplayBlock(self, NO);
                    }
                });
                return;
            }

            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancelledBlock()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (transaction.didDisplayBlock) {
                        transaction.didDisplayBlock(self, NO);
                    }
                });
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                __weak typeof(self) weakSelf = self;
                VVTransaction *layerAsyncTransaction = self.vv_asyncTransaction;
                [layerAsyncTransaction addAsyncOperationWithTarget:self
                                                          selector:@selector(setContents:)
                                                            object:(__bridge id) (image.CGImage)
                                                        completion:^(BOOL canceled) {
                                                            __strong typeof(weakSelf) swself = weakSelf;
                                                            if (transaction.didDisplayBlock) {
                                                                transaction.didDisplayBlock(swself, !canceled);
                                                            }
                                                        }];
            });
        });
    } else {
        if (transaction.willDisplayBlock) {
            transaction.willDisplayBlock(self);
        }

        UIGraphicsBeginImageContextWithOptions(size, self.opaque, self.contentsScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (self.opaque) {
            size.width *= self.contentsScale;
            size.height *= self.contentsScale;
            CGContextSaveGState(context);
            {
                if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
                if (self.backgroundColor) {
                    CGContextSetFillColorWithColor(context, self.backgroundColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
            }
            CGContextRestoreGState(context);
        }

        transaction.displayBlock(self, context, size, ^{
            return NO;
        });

        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id) (image.CGImage);
        if (transaction.didDisplayBlock) {
            transaction.didDisplayBlock(self, YES);
        }
    }
}

- (void)cancelAsyncDisplay {
    [self.displayFlag increment];
}

@end


@implementation VVAsyncDisplayTransaction

@end

