//
// Created by Jiangmingz on 2019-06-13.
// Copyright (c) 2019 Jiangmingz. All rights reserved.
//

#import "VVIdentifier.h"

@implementation VVIdentifier

- (id)init {
    self = [super init];
    if (self) {
        self.identifier = [[NSUUID UUID] UUIDString];
    }

    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToIdentifier:other];
}

- (BOOL)isEqualToIdentifier:(VVIdentifier *)identifier {
    if (self == identifier)
        return YES;
    if (identifier == nil)
        return NO;
    return !(self.identifier != identifier.identifier && ![self.identifier isEqualToString:identifier.identifier]);
}

- (NSUInteger)hash {
    return [self.identifier hash];
}


@end