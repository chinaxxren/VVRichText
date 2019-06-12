
#import "VVAsyncImageView.h"
#import "VVImageStorage.h"

@interface VVAsyncImageView (WebCache)

/**
 *  设置VVAsyncImageView的图片内容
 */
- (void)vv_setImageWihtImageStorage:(VVImageStorage *)imageStorage
                             resize:(VVHTMLImageResizeBlock)resizeBlock
                         completion:(VVAsyncCompleteBlock)completion;

@end
