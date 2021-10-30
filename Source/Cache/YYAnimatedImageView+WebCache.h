
#import "VVImageView.h"

#import <SDWebImage/SDImageCacheDefine.h>
#import <SDWebImage/SDImageLoader.h>
#import <SDWebImage/SDWebImageManager.h>


@class SDWebImageTransition;
@class VVImageWidget;
@protocol SDWebImageIndicator;


typedef void(^SDSetImageBlock)(UIImage *_Nullable image, NSData *_Nullable imageData, SDImageCacheType cacheType, NSURL *_Nullable imageURL);

@interface YYAnimatedImageView (WebCache)

@property(nonatomic, strong, readonly, nullable) NSURL *sd_imageURL;

@property(nonatomic, strong, null_resettable) NSProgress *sd_imageProgress;

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder;

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
               imageWidget:(nullable VVImageWidget *)imageWidget
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

- (void)sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                       imageWidget:(nullable VVImageWidget *)imageWidget
                           options:(SDWebImageOptions)options
                           context:(nullable SDWebImageContext *)context
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable SDImageLoaderProgressBlock)progressBlock
                         completed:(nullable SDInternalCompletionBlock)completedBlock;

/**
 * Cancel the current image load
 */
- (void)sd_cancelCurrentImageLoad;


#pragma mark - Image Transition

/**
 The image transition when image load finished. See `SDWebImageTransition`.
 If you specify nil, do not do transition. Defautls to nil.
 */
@property(nonatomic, strong, nullable) SDWebImageTransition *sd_imageTransition;

#pragma mark - Image Indicator

/**
 The image indicator during the image loading. If you do not need indicator, specify nil. Defaults to nil
 The setter will remove the old indicator view and add new indicator view to current view's subview.
 @note Because this is UI related, you should access only from the main queue.
 */
@property(nonatomic, strong, nullable) id <SDWebImageIndicator> sd_imageIndicator;


@end
