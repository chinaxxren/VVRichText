

#import <UIKit/UIKit.h>


/**
 *  对UIImage的扩展
 *
 */
@interface UIImage (VVRichText)

/**
 *  将一张图片按照contentMode和指定的size处理
 *
 */
- (UIImage *)vv_processedImageWithContentMode:(UIViewContentMode)contentMode size:(CGSize)size;


/**
 *  在指定区域内按照UIViewContentMode的样式和是否clips绘制
 *
 */
- (void)vv_drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;


/**
 *  纠正图片的方向
 *
 */
- (UIImage *)vv_fixOrientation;


/**
 *  根据颜色生成纯色图片
 *
 */
+ (UIImage *)vv_imageWithColor:(UIColor *)color;

/**
 *  取图片某一像素的颜色
 *
 */
- (UIColor *)vv_colorAtPixel:(CGPoint)point;

/**
 *  获得灰度图
 *
 */
- (UIImage *)vv_convertToGrayImage;


/**
 *  用一个Gif生成UIImage
 *
 *  @param theData 传入一个GIFData对象
 */
+ (UIImage *)vv_animatedImageWithAnimatedGIFData:(NSData *)theData;

/**
 *  用一个Gif生成UIImage
 *
 *  @param theURL 传入一个GIF路径
 */
+ (UIImage *)vv_animatedImageWithAnimatedGIFURL:(NSURL *)theURL;

/**
 *  按给定的方向旋转图片
 *
 */
- (UIImage *)vv_rotate:(UIImageOrientation)orient;

/**
 *  垂直翻转
 *
 */
- (UIImage *)vv_flipVertical;

/**
 *  水平翻转
 *
 */
- (UIImage *)vv_flipHorizontal;


/**
 *  将图片旋转degrees角度
 *
 */
- (UIImage *)vv_imageRotatedByDegrees:(CGFloat)degrees;

/**
 *  将图片旋转radians弧度
 *
 */
- (UIImage *)vv_imageRotatedByRadians:(CGFloat)radians;

/**
 * 截取当前image对象rect区域内的图像
 *
 */
- (UIImage *)vv_subImageWithRect:(CGRect)rect;

/**
 * 压缩图片至指定尺寸
 *
 */
- (UIImage *)vv_rescaleImageToSize:(CGSize)size;

/**
 * 压缩图片至指定像素
 *
 */
- (UIImage *)vv_rescaleImageToPX:(CGFloat)toPX;

/**
 * 在指定的size里面生成一个平铺的图片
 *
 */
- (UIImage *)vv_getTiledImageWithSize:(CGSize)size;


/**
 * UIView转化为UIImage
 *
 */
+ (UIImage *)vv_imageFromView:(UIView *)view;

/**
 * 将两个图片生成一张图片
 *
 */
+ (UIImage *)vv_mergeImage:(UIImage *)firstImage withImage:(UIImage *)secondImage;

/**
 * 图片模糊处理
 *
 */
- (UIImage *)vv_applyBlurWithRadius:(CGFloat)blurRadius
                          tintColor:(UIColor *)tintColor
              saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                          maskImage:(UIImage *)maskImage;

@end
