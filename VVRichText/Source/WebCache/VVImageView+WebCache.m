


#import "VVImageView+WebCache.h"

#import "UIImage+VVRichText.h"
#import "YYAnimatedImageView+WebCache.h"

static CGSize _sizeFitWithAspectRatio(CGFloat aspectRatio, CGSize constraints);

static CGSize _sizeFillWithAspectRatio(CGFloat sizeToScaleAspectRatio, CGSize destinationSize);

static void _croppedImageBackingSizeAndDrawRectInBounds(CGSize sourceImageSize, CGSize boundsSize, UIViewContentMode contentMode, CGRect cropRect, BOOL forceUpscaling, CGSize *outBackingSize, CGRect *outDrawRect);

@implementation VVImageView (WebCache)

- (void)vv_setImageWihtImageWidget:(VVImageWidget *)imageWidget resize:(VVImageResizeBlock)resize completion:(VVAsynCompleteBlock)completion {
    if ([imageWidget.contents isKindOfClass:[UIImage class]]) {
        [self _setLocalImageWithImageWidget:imageWidget resizeBlock:resize completion:completion];
    } else {
        [self _setWebImageWithImageWidget:imageWidget resize:resize completion:completion];
    }
}

- (void)_setLocalImageWithImageWidget:(VVImageWidget *)imageWidget resizeBlock:(VVImageResizeBlock)resize completion:(VVAsynCompleteBlock)completion {
    if (imageWidget.needRerendering) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *processedImage = [self _reRenderingImageWitImageWidget:imageWidget];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = processedImage;
                if (resize) {
                    resize(imageWidget, 0);
                }
                if (completion) {
                    completion();
                }
            });
        });
    } else {
        UIImage *image = (UIImage *) imageWidget.contents;
        self.image = image;
        if (resize) {
            resize(imageWidget, 0);
        }
        if (completion) {
            completion();
        }
    }
}

- (UIImage *)_reRenderingImageWitImageWidget:(VVImageWidget *)imageWidget {

    UIImage *image = (UIImage *) imageWidget.contents;
    if (!image) {
        return nil;
    }

    @autoreleasepool {
        if (imageWidget.isBlur) {
            image = [image vv_applyBlurWithRadius:20.0f tintColor:VV_COLOR(0, 0, 0, 0.15f) saturationDeltaFactor:1.4 maskImage:nil];
        }

        BOOL forceUpscaling = NO;
        BOOL cropEnabled = YES;
        BOOL isOpaque = imageWidget.opaque;
        UIColor *backgroundColor = imageWidget.backgroundColor;
        UIViewContentMode contentMode = imageWidget.contentMode;
        CGFloat contentsScale = imageWidget.contentsScale;
        CGRect cropDisplayBounds = CGRectZero;
        CGRect cropRect = CGRectMake(0.5f, 0.5f, 0.0f, 0.0f);
        BOOL hasValidCropBounds = cropEnabled && !CGRectIsNull(cropDisplayBounds) && !CGRectIsEmpty(cropDisplayBounds);
        CGRect bounds = (hasValidCropBounds ? cropDisplayBounds : imageWidget.bounds);
        CGSize imageSize = image.size;
        CGSize imageSizeInPixels = CGSizeMake(imageSize.width * image.scale, imageSize.height * image.scale);
        CGSize boundsSizeInPixels = CGSizeMake(floorf(bounds.size.width * contentsScale), floorf(bounds.size.height * contentsScale));
        BOOL contentModeSupported = contentMode == UIViewContentModeScaleAspectFill ||
                contentMode == UIViewContentModeScaleAspectFit ||
                contentMode == UIViewContentModeCenter;
        CGSize backingSize = CGSizeZero;
        CGRect imageDrawRect = CGRectZero;

        CGFloat cornerRadius = imageWidget.cornerRadius;
        UIColor *cornerBackgroundColor = imageWidget.cornerBackgroundColor;
        UIColor *cornerBorderColor = imageWidget.cornerBorderColor;
        CGFloat cornerBorderWidth = imageWidget.cornerBorderWidth;

        if (boundsSizeInPixels.width * contentsScale < 1.0f || boundsSizeInPixels.height * contentsScale < 1.0f ||
                imageSizeInPixels.width < 1.0f || imageSizeInPixels.height < 1.0f) {
            return nil;
        }

        if (!cropEnabled || !contentModeSupported) {
            backingSize = imageSizeInPixels;
            imageDrawRect = (CGRect) {.size = backingSize};

        } else {
            _croppedImageBackingSizeAndDrawRectInBounds(imageSizeInPixels,
                    boundsSizeInPixels,
                    contentMode,
                    cropRect,
                    forceUpscaling,
                    &backingSize,
                    &imageDrawRect);
        }
        if (backingSize.width <= 0.0f || backingSize.height <= 0.0f ||
                imageDrawRect.size.width <= 0.0f || imageDrawRect.size.height <= 0.0f) {
            return nil;
        }

        UIGraphicsBeginImageContextWithOptions(backingSize, isOpaque, contentsScale);
        if (nil == UIGraphicsGetCurrentContext()) {
            return nil;
        }

        if (isOpaque && backgroundColor) {
            [backgroundColor setFill];
            UIRectFill(CGRectMake(0.0f, 0.0f, backingSize.width, backingSize.height));
        }

        UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:imageDrawRect
                                                              cornerRadius:cornerRadius * contentsScale];

        UIBezierPath *backgroundRect = [UIBezierPath bezierPathWithRect:imageDrawRect];
        if (cornerBackgroundColor) {
            [cornerBackgroundColor setFill];
        }
        [backgroundRect fill];
        [cornerPath addClip];


        [image drawInRect:imageDrawRect];

        if (cornerBorderColor) {
            [cornerBorderColor setStroke];
        }
        [cornerPath stroke];
        [cornerPath setLineWidth:cornerBorderWidth];

        CGImageRef processedImageRef = (UIGraphicsGetImageFromCurrentImageContext().CGImage);
        UIGraphicsEndImageContext();
        return [UIImage imageWithCGImage:processedImageRef];
    }
}

- (void)_setWebImageWithImageWidget:(VVImageWidget *)imageWidget resize:(VVImageResizeBlock)resize completion:(VVAsynCompleteBlock)completion {
    NSURL *url;
    id placeholder = imageWidget.placeholder;
    BOOL needResize = imageWidget.needResize;
    if ([imageWidget.contents isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:imageWidget.contents];
    } else if ([imageWidget.contents isKindOfClass:[NSURL class]]) {
        url = (NSURL *) imageWidget.contents;
    } else {
        resize(imageWidget, 0);
        if (completion) {
            completion();
        }
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder imageWidget:imageWidget completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
        if (!image) {
            if (completion) {
                completion();
            }
            return;
        }

        __strong typeof(weakSelf) sself = weakSelf;
        if (needResize) {
            CGFloat delta = [sself _resizeImageWidget:imageWidget image:image];
            sself.frame = imageWidget.frame;
            resize(imageWidget, delta);
        }

        if (completion) {
            completion();
        }
    }];
}

- (CGFloat)_resizeImageWidget:(VVImageWidget *)imageWidget image:(UIImage *)image {
    CGSize imageSize = image.size;
    CGFloat imageScale = imageSize.height / imageSize.width;
    CGSize reSize = CGSizeMake(imageWidget.bounds.size.width, imageWidget.bounds.size.width * imageScale);
    CGFloat delta = reSize.height - imageWidget.frame.size.height;
    imageWidget.frame = CGRectMake(imageWidget.frame.origin.x,
            imageWidget.frame.origin.y,
            imageWidget.frame.size.width,
            imageWidget.frame.size.height + delta);
    return delta;
}

@end

static void _croppedImageBackingSizeAndDrawRectInBounds(CGSize sourceImageSize,
        CGSize boundsSize,
        UIViewContentMode contentMode,
        CGRect cropRect,
        BOOL forceUpscaling,
        CGSize *outBackingSize,
        CGRect *outDrawRect) {
    size_t destinationWidth = boundsSize.width;
    size_t destinationHeight = boundsSize.height;
    CGFloat boundsAspectRatio = (float) destinationWidth / (float) destinationHeight;

    CGSize scaledSizeForImage = sourceImageSize;
    BOOL cropToRectDimensions = !CGRectIsEmpty(cropRect);

    if (cropToRectDimensions) {
        scaledSizeForImage = CGSizeMake(boundsSize.width / cropRect.size.width, boundsSize.height / cropRect.size.height);
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill)
            scaledSizeForImage = _sizeFillWithAspectRatio(boundsAspectRatio, sourceImageSize);
        else if (contentMode == UIViewContentModeScaleAspectFit)
            scaledSizeForImage = _sizeFitWithAspectRatio(boundsAspectRatio, sourceImageSize);
    }

    if (!forceUpscaling && (scaledSizeForImage.width * scaledSizeForImage.height) < (destinationWidth * destinationHeight)) {
        destinationWidth = (size_t) roundf(scaledSizeForImage.width);
        destinationHeight = (size_t) roundf(scaledSizeForImage.height);
        if (destinationWidth == 0 || destinationHeight == 0) {
            *outBackingSize = CGSizeZero;
            *outDrawRect = CGRectZero;
            return;
        }
    }

    CGFloat sourceImageAspectRatio = sourceImageSize.width / sourceImageSize.height;
    CGSize scaledSizeForDestination = CGSizeMake(destinationWidth, destinationHeight);
    if (cropToRectDimensions) {
        scaledSizeForDestination = CGSizeMake(boundsSize.width / cropRect.size.width, boundsSize.height / cropRect.size.height);
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill)
            scaledSizeForDestination = _sizeFillWithAspectRatio(sourceImageAspectRatio, scaledSizeForDestination);
        else if (contentMode == UIViewContentModeScaleAspectFit)
            scaledSizeForDestination = _sizeFitWithAspectRatio(sourceImageAspectRatio, scaledSizeForDestination);
    }

    CGRect drawRect = CGRectZero;
    if (cropToRectDimensions) {
        drawRect = CGRectMake(-cropRect.origin.x * scaledSizeForDestination.width,
                -cropRect.origin.y * scaledSizeForDestination.height,
                scaledSizeForDestination.width,
                scaledSizeForDestination.height);
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill) {
            drawRect = CGRectMake(((destinationWidth - scaledSizeForDestination.width) * cropRect.origin.x),
                    ((destinationHeight - scaledSizeForDestination.height) * cropRect.origin.y),
                    scaledSizeForDestination.width,
                    scaledSizeForDestination.height);

        } else {
            drawRect = CGRectMake(((destinationWidth - scaledSizeForDestination.width) * 0.5f),
                    ((destinationHeight - scaledSizeForDestination.height) * 0.5f),
                    scaledSizeForDestination.width,
                    scaledSizeForDestination.height);
        }
    }
    *outDrawRect = drawRect;
    *outBackingSize = CGSizeMake(destinationWidth, destinationHeight);
}

static CGSize _sizeFillWithAspectRatio(CGFloat sizeToScaleAspectRatio, CGSize destinationSize) {
    CGFloat destinationAspectRatio = destinationSize.width / destinationSize.height;
    if (sizeToScaleAspectRatio > destinationAspectRatio) {
        return CGSizeMake(destinationSize.height * sizeToScaleAspectRatio, destinationSize.height);
    } else {
        return CGSizeMake(destinationSize.width, floorf(destinationSize.width / sizeToScaleAspectRatio));
    }
}

static CGSize _sizeFitWithAspectRatio(CGFloat aspectRatio, CGSize constraints) {
    CGFloat constraintAspectRatio = constraints.width / constraints.height;
    if (aspectRatio > constraintAspectRatio) {
        return CGSizeMake(constraints.width, constraints.width / aspectRatio);
    } else {
        return CGSizeMake(constraints.height * aspectRatio, constraints.height);
    }
}

