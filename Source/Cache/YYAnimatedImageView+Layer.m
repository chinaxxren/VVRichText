//
//  YYAnimatedImageView+Layer.m
//  VVRichText
//
//  Created by 赵江明 on 2021/10/29.
//  Copyright © 2021 Jiangmingz. All rights reserved.
//

#import "YYAnimatedImageView+Layer.h"

#import <objc/runtime.h>

@implementation YYAnimatedImageView (Layer)

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        Method displayLayerMethod = class_getInstanceMethod(self, @selector(displayLayer:));
        Method displayLayerNewMethod = class_getInstanceMethod(self, @selector(displayLayerNew:));
        method_exchangeImplementations(displayLayerMethod, displayLayerNewMethod);
    });
}

- (void)displayLayerNew:(CALayer *)layer {
    Ivar imgIvar = class_getInstanceVariable([self class], "_curFrame");
    UIImage *img = object_getIvar(self, imgIvar);
    if (img) {
        layer.contents = (__bridge id)img.CGImage;
    } else {
        if (@available(iOS 14.0, *)) {
            [super displayLayer:layer];
        }
    }
}

@end
