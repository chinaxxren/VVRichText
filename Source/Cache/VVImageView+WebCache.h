
#import "VVImageView.h"
#import "VVImageWidget.h"

@interface VVImageView (WebCache)

/**
 *  设置VVAsyncImageView的图片内容
 */
- (void)vv_setImageWihtImageWidget:(VVImageWidget *)imageWidget
                            resize:(VVImageResizeBlock)resize
                        completion:(VVAsynCompleteBlock)completion;

@end
