//
// Created by Jiangmingz on 2019-06-13.
// Copyright (c) 2019 Jiangmingz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VVIdentifier : NSObject

//一个标示字符串，可以用于复用时取到属性相同的对象
@property(nonatomic, copy, nonnull) NSString *identifier;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToIdentifier:(VVIdentifier *)identifier;

- (NSUInteger)hash;

@end
