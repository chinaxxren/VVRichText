
#import "VVAsyncImageView.h"
#import "VVImageStorage.h"

@interface VVAsyncImageView (WebCache)

/**
 *  设置VVAsyncImageView的图片内容
 *  @param imageStorage          VVImageStorage对象
 *  @param placeholder           这个block用于VVHTMLDisplayView渲染时，自动调整图片的比例
 *  @param cornerRadius          这个block图像显示完毕后回调
 */

- (void)vv_setImageWihtImageStorage:(VVImageStorage *)imageStorage
                             resize:(VVHTMLImageResizeBlock)resizeBlock
                         completion:(VVAsyncCompleteBlock)completion;

@end
