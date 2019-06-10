//
// Created by Jiangmingz on 2019-06-05.
// Copyright (c) 2019 Jiangmingz. All rights reserved.
//

#import "CALayer+WebCache.h"

#import <SDWebImage/SDWebImageError.h>

#import "objc/runtime.h"
#import "CALayer+WebCacheOperation.h"
#import "CALayer+VVTransaction.h"

@implementation CALayer (WebCache)

- (nullable NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, @selector(sd_imageURL));
}

- (void)setSd_imageURL:(NSURL *_Nullable)sd_imageURL {
    objc_setAssociatedObject(self, @selector(sd_imageURL), sd_imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSString *)sd_latestOperationKey {
    return objc_getAssociatedObject(self, @selector(sd_latestOperationKey));
}

- (void)setSd_latestOperationKey:(NSString *_Nullable)sd_latestOperationKey {
    objc_setAssociatedObject(self, @selector(sd_latestOperationKey), sd_latestOperationKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(SDWebImageOptions)options
                           context:(nullable SDWebImageContext *)context
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable SDImageLoaderProgressBlock)progressBlock
                         completed:(nullable SDInternalCompletionBlock)completedBlock {
    context = [context copy]; // copy to avoid mutable object
    NSString *validOperationKey = context[SDWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        validOperationKey = NSStringFromClass([self class]);
    }
    self.sd_latestOperationKey = validOperationKey;
    [self sd_cancelImageLoadOperationWithKey:validOperationKey];
    self.sd_imageURL = url;

    if (!(options & SDWebImageDelayPlaceholder)) {
        [self.vv_asyncTransaction addAsyncOperationWithTarget:self
                                                     selector:@selector(setContents:)
                                                       object:(__bridge id) placeholder.CGImage
                                                   completion:^(BOOL canceled) {
                                                   }];
    }

    if (url) {
        SDWebImageManager *manager = context[SDWebImageContextCustomManager];
        if (!manager) {
            manager = [SDWebImageManager sharedManager];
        }

        __weak typeof(self) weakSelf = self;
        id <SDWebImageOperation> operation = [manager loadImageWithURL:url options:options context:context progress:progressBlock completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            __strong typeof(weakSelf) sself = weakSelf;

            if (!sself || !image) {
                completedBlock(image, data, error, cacheType, finished, imageURL);
                return;
            }

            dispatch_main_async_safe(^{
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock) {
                    completedBlock(image, data, error, cacheType, finished, imageURL);
                    return;
                } else if (image) {
                    [sself.vv_asyncTransaction addAsyncOperationWithTarget:self
                                                                  selector:@selector(setContents:)
                                                                    object:(__bridge id) image.CGImage
                                                                completion:nil];
                    [sself setNeedsLayout];
                } else if (options & SDWebImageDelayPlaceholder) {
                    [sself.vv_asyncTransaction addAsyncOperationWithTarget:self
                                                                  selector:@selector(setContents:)
                                                                    object:(__bridge id) placeholder.CGImage
                                                                completion:nil];
                    [sself setNeedsLayout];
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
        dispatch_main_async_safe(^{
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey: @"Image url is nil"}];
                completedBlock(nil, nil, error, SDImageCacheTypeNone, YES, url);
            }
        });
    }
}

- (void)sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:self.sd_latestOperationKey];
}

@end
