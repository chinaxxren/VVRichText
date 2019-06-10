
#import "VVLayout.h"

#import <objc/runtime.h>


@interface VVLayout ()

@property(nonatomic, strong) NSMutableArray<VVTextStorage *> *textStorages;
@property(nonatomic, strong) NSMutableArray<VVImageStorage *> *imageStorages;
@property(nonatomic, strong) NSMutableArray<VVStorage *> *totalStorages;

@end

@implementation VVLayout


#pragma mark - Override Hash & isEqual

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (!object || ![object isKindOfClass:[VVLayout class]]) {
        return NO;
    }
    VVLayout *layout = (VVLayout *) object;
    return ([layout.textStorages isEqual:self.textStorages] && [layout.imageStorages isEqual:self.imageStorages]);
}

- (NSUInteger)hash {
    long v1 = (long) ((__bridge void *) self.textStorages);
    long v2 = (long) ((__bridge void *) self.imageStorages);
    return v1 ^ v2;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.textStorages forKey:@"textStorages"];
    [aCoder encodeObject:self.imageStorages forKey:@"imageStorages"];
    [aCoder encodeObject:self.totalStorages forKey:@"totalStorages"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.textStorages = [aDecoder decodeObjectForKey:@"textStorages"];
        self.imageStorages = [aDecoder decodeObjectForKey:@"imageStorages"];
        self.totalStorages = [aDecoder decodeObjectForKey:@"totalStorages"];
    }
    return self;
}

- (void)addStorage:(VVStorage *)storage {
    if (!storage) {
        return;
    }

    if ([storage isMemberOfClass:[VVTextStorage class]]) {
        VVTextStorage *textStorage = (VVTextStorage *) storage;
        [textStorage creatLayout];
        [self.textStorages addObject:textStorage];
    } else if ([storage isMemberOfClass:[VVImageStorage class]]) {
        [self.imageStorages addObject:(VVImageStorage *) storage];
    }

    [self.totalStorages addObject:storage];
}

- (void)addStorages:(NSArray <VVStorage *> *)storages {
    if (!storages) {
        return;
    }

    for (VVStorage *storage in storages) {
        [self addStorage:storage];
    }

    [self.totalStorages addObjectsFromArray:storages];
}


- (void)removeStorage:(VVStorage *)storage {
    if (!storage) {
        return;
    }

    if ([storage isMemberOfClass:[VVTextStorage class]]) {
        if ([self.textStorages containsObject:storage]) {
            [self.textStorages removeObject:storage];
            [self.totalStorages removeObject:storage];
        }
    } else if ([storage isMemberOfClass:[VVImageStorage class]]) {
        if ([self.imageStorages containsObject:storage]) {
            [self.imageStorages removeObject:storage];
            [self.totalStorages removeObject:storage];
        }
    }
}

- (void)removeStorages:(NSArray <VVStorage *> *)storages {
    if (!storages) {
        return;
    }

    for (VVStorage *storage in storages) {
        [self removeStorage:storage];
    }
}

- (CGFloat)suggestHeightWithBottomMargin:(CGFloat)bottomMargin {
    CGFloat suggestHeight = 0.0f;
    for (VVStorage *storage in self.totalStorages) {
        suggestHeight = suggestHeight > storage.bottom ? suggestHeight : storage.bottom;
    }
    return suggestHeight + bottomMargin;
}

#pragma mark - Getter

- (NSMutableArray *)textStorages {
    if (_textStorages) {
        return _textStorages;
    }
    _textStorages = [NSMutableArray new];
    return _textStorages;
}

- (NSMutableArray *)imageStorages {
    if (_imageStorages) {
        return _imageStorages;
    }
    _imageStorages = [NSMutableArray new];
    return _imageStorages;
}

- (NSMutableArray *)totalStorages {
    if (_totalStorages) {
        return _totalStorages;
    }
    _totalStorages = [NSMutableArray new];
    return _totalStorages;
}


@end