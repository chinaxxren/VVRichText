
#import "VVFlag.h"

#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

@implementation VVFlag {
    int32_t _value;
}

- (int32_t)value {
    return _value;
}

- (int32_t)increment {
    return OSAtomicIncrement32(&_value);
}

@end
