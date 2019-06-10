

#import "VVAsyncImageView.h"

#import "VVTransaction.h"
#import "CALayer+VVTransaction.h"

@interface VVAsyncImageView ()

@end

@implementation VVAsyncImageView

- (void)setHidden:(BOOL)hidden {
    if (self.displayAsynchronously) {
        [self.layer.vv_asyncTransaction addAsyncOperationWithTarget:self
                                                           selector:@selector(_setHidden:)
                                                             object:@(hidden)
                                                         completion:nil];
    } else {
        [super setHidden:hidden];
    }
}

- (void)_setHidden:(NSNumber *)hidden {
    [super setHidden:[hidden boolValue]];
}

- (void)setFrame:(CGRect)frame {
    if (self.displayAsynchronously) {
        [self.layer.vv_asyncTransaction addAsyncOperationWithTarget:self
                                                           selector:@selector(_setFrameValue:)
                                                             object:[NSValue valueWithCGRect:frame]
                                                         completion:nil];
    } else {
        [super setFrame:frame];
    }
}

- (void)_setFrameValue:(NSValue *)frameValue {
    if (!CGRectEqualToRect(super.frame, [frameValue CGRectValue])) {
        [super setFrame:[frameValue CGRectValue]];
    }
}

@end


