
#import "YYAnimatedImageView+WebCache.h"

#import <objc/runtime.h>
#import <SDWebImage/UIView+WebCacheOperation.h>
#import <SDWebImage/SDWebImageError.h>
#import <SDWebImage/SDInternalMacros.h>
#import <SDWebImage/UIView+WebCache.h>

#import "YYImage+SDAdditions.h"
#import "VVImageProcessor.h"
#import "VVImageWidget.h"

const int64_t SDWebImageProgressUnitCountUnknown = 1LL;

@implementation YYAnimatedImageView (WebCache)

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

- (NSProgress *)sd_imageProgress {
    NSProgress *progress = objc_getAssociatedObject(self, @selector(sd_imageProgress));
    if (!progress) {
        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.sd_imageProgress = progress;
    }
    return progress;
}

- (void)setSd_imageProgress:(NSProgress *)sd_imageProgress {
    objc_setAssociatedObject(self, @selector(sd_imageProgress), sd_imageProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder imageWidget:nil completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder imageWidget:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
               imageWidget:(nullable VVImageWidget *)imageWidget
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                         imageWidget:imageWidget
                             options:0
                             context:nil
                       setImageBlock:nil
                            progress:nil
                           completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}


- (void)sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                       imageWidget:(nullable VVImageWidget *)imageWidget
                           options:(SDWebImageOptions)options
                           context:(nullable SDWebImageContext *)context
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable SDImageLoaderProgressBlock)progressBlock
                         completed:(nullable SDInternalCompletionBlock)completedBlock {

    Class animatedImageClass = [YYImage class];
    SDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[SDWebImageContextAnimatedImageClass] = animatedImageClass;

    NSString *validOperationKey = mutableContext[SDWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        validOperationKey = NSStringFromClass([self class]);
    }
    self.sd_latestOperationKey = validOperationKey;
    [self sd_cancelImageLoadOperationWithKey:validOperationKey];
    self.sd_imageURL = url;

    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            [self sd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:SDImageCacheTypeNone imageURL:url];
        });
    }

    if (url) {
        // reset the progress
        self.sd_imageProgress.totalUnitCount = 0;
        self.sd_imageProgress.completedUnitCount = 0;

        // check and start image indicator
        [self sd_startImageIndicator];
        id <SDWebImageIndicator> imageIndicator = self.sd_imageIndicator;

        SDWebImageManager *manager = mutableContext[SDWebImageContextCustomManager];
        if (!manager) {
            manager = [SDWebImageManager sharedManager];
        }

        @weakify(self);
        SDImageLoaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {
            @strongify(self);
            NSProgress *imageProgress = self.sd_imageProgress;
            imageProgress.totalUnitCount = expectedSize;
            imageProgress.completedUnitCount = receivedSize;

            if ([imageIndicator respondsToSelector:@selector(updateIndicatorProgress:)]) {
                double progress = imageProgress.fractionCompleted;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageIndicator updateIndicatorProgress:progress];
                });
            }

            if (progressBlock) {
                progressBlock(receivedSize, expectedSize, targetURL);
            }
        };
        id <SDWebImageOperation> operation = [manager loadImageWithURL:url options:options context:mutableContext progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @strongify(self);
            if (!self) {return;}
            // if the progress not been updated, mark it to complete state
            if (finished && !error && self.sd_imageProgress.totalUnitCount == 0 && self.sd_imageProgress.completedUnitCount == 0) {
                self.sd_imageProgress.totalUnitCount = SDWebImageProgressUnitCountUnknown;
                self.sd_imageProgress.completedUnitCount = SDWebImageProgressUnitCountUnknown;
            }

            // check and stop image indicator
            if (finished) {
                [self sd_stopImageIndicator];
            }

            BOOL shouldCallCompletedBlock = finished || (options & SDWebImageAvoidAutoSetImage);
            BOOL shouldNotSetImage = ((image && (options & SDWebImageAvoidAutoSetImage)) ||
                    (!image && !(options & SDWebImageDelayPlaceholder)));
            SDWebImageNoParamsBlock callCompletedBlockClojure = ^{
                if (!self) {return;}
                if (!shouldNotSetImage) {
                    [self setNeedsLayout];
                }
                if (completedBlock && shouldCallCompletedBlock) {
                    completedBlock(image, data, error, cacheType, finished, url);
                }
            };

            // case 1a: we got an image, but the SDWebImageAvoidAutoSetImage flag is set
            // OR
            // case 1b: we got no image and the SDWebImageDelayPlaceholder is not set
            if (shouldNotSetImage) {
                dispatch_main_async_safe(callCompletedBlockClojure);
                return;
            }

            UIImage *targetImage = nil;
            NSData *targetData = nil;
            if (image) {
                // case 2a: we got an image and the SDWebImageAvoidAutoSetImage is not set
                YYImage *yyImage = (YYImage *) image;
                if (!imageWidget || yyImage.animatedImageType == YYImageTypeGIF) {
                    targetImage = image;
                } else {
                    targetImage = [VVImageProcessor vv_processImage:image
                                                               size:imageWidget.frame.size
                                                        borderWidth:imageWidget.cornerBorderWidth
                                              cornerBackgroundColor:imageWidget.cornerBackgroundColor
                                                        borderColor:imageWidget.cornerBorderColor
                                                               blur:imageWidget.isBlur
                                                        contentMode:imageWidget.contentMode
                                                       cornerRadius:imageWidget.cornerRadius];
                }
                targetData = data;
            } else if (options & SDWebImageDelayPlaceholder) {
                // case 2b: we got no image and the SDWebImageDelayPlaceholder flag is set
                targetImage = placeholder;
                targetData = nil;
            }

            SDWebImageTransition *transition = nil;
            if (finished && (options & SDWebImageForceTransition || cacheType == SDImageCacheTypeNone)) {
                transition = self.sd_imageTransition;
            }

            dispatch_main_async_safe(^{
                [self sd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];
                callCompletedBlockClojure();
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
        [self sd_stopImageIndicator];
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

- (void)sd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(SDSetImageBlock)setImageBlock cacheType:(SDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    [self sd_setImage:image imageData:imageData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:nil cacheType:cacheType imageURL:imageURL];
}

- (void)sd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(SDSetImageBlock)setImageBlock transition:(SDWebImageTransition *)transition cacheType:(SDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    UIView *view = self;
    SDSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    } else if ([view isKindOfClass:[VVImageView class]]) {
        VVImageView *imageView = (VVImageView *) view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, SDImageCacheType setCacheType, NSURL *setImageURL) {
            imageView.image = setImage;
        };
    }

    if (transition) {
        [UIView transitionWithView:view duration:0 options:0 animations:^{
            // 0 duration to let UIKit render placeholder and prepares block
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        }               completion:^(BOOL finished) {
            [UIView transitionWithView:view duration:transition.duration options:transition.animationOptions animations:^{
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            }               completion:transition.completion];
        }];
    } else {
        if (finalSetImageBlock) {
            finalSetImageBlock(image, imageData, cacheType, imageURL);
        }
    }
}

#pragma mark - Image Transition

- (SDWebImageTransition *)sd_imageTransition {
    return objc_getAssociatedObject(self, @selector(sd_imageTransition));
}

- (void)setSd_imageTransition:(SDWebImageTransition *)sd_imageTransition {
    objc_setAssociatedObject(self, @selector(sd_imageTransition), sd_imageTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Indicator

- (id <SDWebImageIndicator>)sd_imageIndicator {
    return objc_getAssociatedObject(self, @selector(sd_imageIndicator));
}

- (void)setSd_imageIndicator:(id <SDWebImageIndicator>)sd_imageIndicator {
    // Remove the old indicator view
    id <SDWebImageIndicator> previousIndicator = self.sd_imageIndicator;
    [previousIndicator.indicatorView removeFromSuperview];

    objc_setAssociatedObject(self, @selector(sd_imageIndicator), sd_imageIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // Add the new indicator view
    UIView *view = sd_imageIndicator.indicatorView;
    if (CGRectEqualToRect(view.frame, CGRectZero)) {
        view.frame = self.bounds;
    }

    view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    view.hidden = NO;
    [self addSubview:view];
}

- (void)sd_startImageIndicator {
    id <SDWebImageIndicator> imageIndicator = self.sd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator startAnimatingIndicator];
    });
}

- (void)sd_stopImageIndicator {
    id <SDWebImageIndicator> imageIndicator = self.sd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator stopAnimatingIndicator];
    });
}

@end
