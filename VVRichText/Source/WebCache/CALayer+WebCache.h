//
// Created by Jiangmingz on 2019-06-05.
// Copyright (c) 2019 Jiangmingz. All rights reserved.
//

#import <SDWebImage/SDWebImageCompat.h>
#import <SDWebImage/SDWebImageDefine.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageTransition.h>

typedef void(^SDSetImageBlock)(UIImage *_Nullable image, NSData *_Nullable imageData, SDImageCacheType cacheType, NSURL *_Nullable imageURL);

@interface CALayer (WebCache)

@property(nonatomic, strong, readonly, nullable) NSURL *sd_imageURL;

- (void)sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(SDWebImageOptions)options
                           context:(nullable SDWebImageContext *)context
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable SDImageLoaderProgressBlock)progressBlock
                         completed:(nullable SDInternalCompletionBlock)completedBlock;

/**
 * Cancel the current image load
 */
- (void)sd_cancelCurrentImageLoad;

@end
