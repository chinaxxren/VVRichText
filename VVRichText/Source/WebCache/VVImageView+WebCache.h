
#import "VVImageView.h"
#import "VVImageStorage.h"

@interface VVImageView (WebCache)

/**
 *  设置VVAsyncImageView的图片内容
 */
- (void)vv_setImageWihtImageStorage:(VVImageStorage *)imageStorage
                             resize:(VVImageResizeBlock)resizeBlock
                         completion:(VVAsynCompleteBlock)completion;

@end
