
#import "VVTextRunDelegate.h"

#import <objc/runtime.h>
#import "VVRichTextUtils.h"

// 销毁函数指针
static void VVTextDeallocCallback(void *ref);

// 返回字形Ascent
static CGFloat VVTextAscentCallback(void *ref);

// 返回字形Descent
static CGFloat VVTextDescentCallback(void *ref);

// 返回字形Width
static CGFloat VVTextWidthCallback(void *ref);

@implementation VVTextRunDelegate

#pragma mark - Getter

- (CTRunDelegateRef)CTRunDelegate {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = VVTextDeallocCallback;
    callbacks.getAscent = VVTextAscentCallback;
    callbacks.getDescent = VVTextDescentCallback;
    callbacks.getWidth = VVTextWidthCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *) ([self copy]));
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.ascent = [aDecoder decodeFloatForKey:@"ascent"];
        self.descent = [aDecoder decodeFloatForKey:@"descent"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeFloat:self.ascent forKey:@"ascent"];
    [aCoder encodeFloat:self.descent forKey:@"descent"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.height forKey:@"height"];
}


#pragma mark - NSCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    VVTextRunDelegate *delegate = [[[self class] alloc] init];
    delegate.ascent = self.ascent;
    delegate.descent = self.descent;
    delegate.width = self.width;
    delegate.height = self.height;
    delegate.userInfo = [self.userInfo copy];
    return delegate;
}

@end

static void VVTextDeallocCallback(void *ref) {
    VVTextRunDelegate *self = (__bridge_transfer VVTextRunDelegate *) (ref);
    self = nil;
}

static CGFloat VVTextAscentCallback(void *ref) {
    VVTextRunDelegate *self = (__bridge VVTextRunDelegate *) (ref);
    return self.ascent;
}

static CGFloat VVTextDescentCallback(void *ref) {
    VVTextRunDelegate *self = (__bridge VVTextRunDelegate *) (ref);
    return self.descent;
}

static CGFloat VVTextWidthCallback(void *ref) {
    VVTextRunDelegate *self = (__bridge VVTextRunDelegate *) (ref);
    return self.width;
}
