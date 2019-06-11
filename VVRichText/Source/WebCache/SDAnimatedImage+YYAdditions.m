
#import "SDAnimatedImage+YYAdditions.h"

@implementation SDAnimatedImage (YYAdditions)

#pragma mark - YYAnimatedImage

- (NSUInteger)animatedImageBytesPerFrame {
    return CGImageGetBytesPerRow(self.CGImage) * CGImageGetHeight(self.CGImage);
}

@end
