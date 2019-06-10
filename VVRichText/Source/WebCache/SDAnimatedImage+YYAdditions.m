//
// Created by Jiangmingz on 2019-06-05.
// Copyright (c) 2019 Jiangmingz. All rights reserved.
//

#import "SDAnimatedImage+YYAdditions.h"

@implementation SDAnimatedImage (YYAdditions)

#pragma mark - YYAnimatedImage

- (NSUInteger)animatedImageBytesPerFrame {
    return CGImageGetBytesPerRow(self.CGImage) * CGImageGetHeight(self.CGImage);
}

@end
