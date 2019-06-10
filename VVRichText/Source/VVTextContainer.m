
#import "VVTextContainer.h"
#import <objc/runtime.h>
#import "VVRichTextUtils.h"
#import "VVRichTextDefine.h"


@interface VVTextContainer ()

@property(nonatomic, assign) CGSize size;
@property(nonatomic, strong) UIBezierPath *path;
@property(nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation VVTextContainer {
    dispatch_semaphore_t _lock;
    CGFloat _pathLineWidth;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    VVTextContainer *one = [[VVTextContainer alloc] init];
    one.vericalAlignment = self.vericalAlignment;
    one.size = self.size;
    one.path = [self.path copy];
    one.edgeInsets = self.edgeInsets;
    one.maxNumberOfLines = self.maxNumberOfLines;
    return one;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.vericalAlignment forKey:@"vericalAlignment"];
    [aCoder encodeCGSize:self.size forKey:@"size"];
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeUIEdgeInsets:self.edgeInsets forKey:@"edgeInsets"];
    [aCoder encodeInteger:self.maxNumberOfLines forKey:@"maxNumberOfLines"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.vericalAlignment = [aDecoder decodeIntegerForKey:@"vericalAlignment"];
        self.size = [aDecoder decodeCGSizeForKey:@"size"];
        self.path = [aDecoder decodeObjectForKey:@"path"];
        self.edgeInsets = [aDecoder decodeUIEdgeInsetsForKey:@"edgeInsets"];
        self.maxNumberOfLines = [aDecoder decodeIntegerForKey:@"maxNumberOfLines"];
    }
    return self;
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _lock = dispatch_semaphore_create(1);
    return self;
}


+ (id)vv_textContainerWithSize:(CGSize)size {
    VVTextContainer *textContainer = [[VVTextContainer alloc] init];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    textContainer.path = bezierPath;
    textContainer.size = size;
    textContainer.edgeInsets = UIEdgeInsetsZero;
    textContainer.maxNumberOfLines = 0;
    textContainer.vericalAlignment = VVTextVericalAlignmentTop;
    return textContainer;
}

+ (id)vv_textContainerWithSize:(CGSize)size edgeInsets:(UIEdgeInsets)edgeInsets {
    VVTextContainer *textContainer = [[VVTextContainer alloc] init];
    CGRect rect = (CGRect) {CGPointZero, size};
    rect = UIEdgeInsetsInsetRect(rect, edgeInsets);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:rect];
    textContainer.path = bezierPath;
    textContainer.size = size;
    textContainer.edgeInsets = edgeInsets;
    textContainer.maxNumberOfLines = 0;
    textContainer.vericalAlignment = VVTextVericalAlignmentTop;
    return textContainer;
}

#pragma mark - Getter

- (CGFloat)pathLineWidth {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    CGFloat width = _pathLineWidth;
    dispatch_semaphore_signal(_lock);
    return width;
}


@end
