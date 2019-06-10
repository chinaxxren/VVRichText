

#import "VVAsyncDisplayView.h"

#import "VVAsyncImageView.h"
#import "CALayer+VVTransaction.h"
#import "VVAsyncImageView+WebCache.h"
#import "VVFlag.h"
#import "VVImage.h"

@interface VVAsyncDisplayView () <VVAsyncDisplayLayerDelegate>

@property(nonatomic, strong) NSMutableArray *reusePool; //这个数组用来存放暂时不使用的VVAsyncImageView
@property(nonatomic, strong) NSMutableArray *imageContainers; //这个数组用来存放正在使用的VVAsyncImageView
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture; //长按手势
@property(nonatomic, assign) BOOL showingHighlight; //是否正在高亮显示
@property(nonatomic, strong) VVTextHighlight *highlight; //当前的高亮显示
@property(nonatomic, assign) CGPoint highlightAdjustPoint; //高亮的坐标偏移点
@property(nonatomic, assign) CGPoint touchBeganPoint; //记录触摸开始的坐标
@property(nonatomic, strong, readonly) VVFlag *displayFlag; //一个自增的标识类，用于取消绘制。

@end

@implementation VVAsyncDisplayView

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.layer.contentsScale = [VVRichTextUtils contentsScale];
    [self addGestureRecognizer:self.longPressGesture];
    self.layer.opaque = YES;
    self.displaysAsynchronously = YES;

    _showingHighlight = NO;
    _highlight = nil;
    _touchBeganPoint = CGPointZero;
    _highlightAdjustPoint = CGPointZero;
    _displayFlag = [[VVFlag alloc] init];
}

- (void)setLayout:(VVLayout *)layout {
    if ([_layout isEqual:layout]) {
        return;
    }

    [self _resetHighlight];
    [self _cleanImageViewAddToReusePool];
    [self _cleanupAndReleaseModelOnSubThread];

    _layout = layout;

    [self.layer setNeedsDisplay];

    __weak typeof(self) weakSelf = self;
    [self setImageStoragesResizeBlock:^(VVImageStorage *imageStorage, CGFloat delta) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.auotoLayoutCallback) {
            strongSelf.auotoLayoutCallback(imageStorage, delta);
        }
    }];
}

#pragma mark - Private

- (void)_resetHighlight {
    _highlightAdjustPoint = CGPointZero;
    _touchBeganPoint = CGPointZero;
    _showingHighlight = NO;
}

- (void)_cleanupAndReleaseModelOnSubThread {
    id <VVLayoutProtocol> oldLayout = _layout;
    VVTextHighlight *oldHighlight = _highlight;

    _layout = nil;
    _highlight = nil;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [oldLayout class];
        [oldHighlight class];
    });
}

- (void)_cleanImageViewAddToReusePool {

    [self.displayFlag increment];

    for (NSInteger i = 0; i < self.imageContainers.count; i++) {
        VVAsyncImageView *container = self.imageContainers[i];
        container.image = nil;
        container.hidden = YES;
        [self.reusePool addObject:container];
    }

    [self.imageContainers removeAllObjects];
}


// 绘制在VVAsyncImageView上
- (void)setImageStoragesResizeBlock:(void (^)(VVImageStorage *imageStorage, CGFloat delta))resizeBlock {

    VVFlag *displayFlag = _displayFlag;
    int32_t value = displayFlag.value;

    VVAsyncDisplayIsCanclledBlock isCancelledBlock = ^BOOL() {
        return value != _displayFlag.value;
    };

    for (NSInteger i = 0; i < self.layout.imageStorages.count; i++) {

        @autoreleasepool {

            if (isCancelledBlock()) {
                return;
            }

            VVAsyncImageView *reuseImageView;
            VVImageStorage *imageStorage = self.layout.imageStorages[i];
            if ([imageStorage.contents isKindOfClass:[VVImage class]]) {
                VVImage *image = (VVImage *) imageStorage.contents;
                if (image.animatedImageType == YYImageTypeGIF) {
                    reuseImageView = [self createPoolAsyncImageView:imageStorage];
                    reuseImageView.image = image;
                    continue;
                }
            }

            if ([imageStorage.contents isKindOfClass:[UIImage class]] && imageStorage.localImageType == VVLocalImageDrawInVVAsyncDisplayView) {
                continue;
            }

            reuseImageView = [self createPoolAsyncImageView:imageStorage];
            if ([imageStorage.contents isKindOfClass:[VVImage class]]) {
                VVImage *image = (VVImage *) imageStorage.contents;
                if (image.animatedImageType == YYImageTypeGIF) {
                    reuseImageView.image = image;
                    continue;
                }
            }

            reuseImageView.clipsToBounds = imageStorage.clipsToBounds;
            reuseImageView.layer.shadowColor = imageStorage.shadowColor.CGColor;
            reuseImageView.layer.shadowOffset = imageStorage.shadowOffset;
            reuseImageView.layer.shadowOpacity = imageStorage.shadowOpacity;
            reuseImageView.layer.shadowRadius = imageStorage.shadowRadius;

            [reuseImageView vv_setImageWihtImageStorage:imageStorage resize:resizeBlock completion:nil];
        }
    }
}

- (VVAsyncImageView *)createPoolAsyncImageView:(VVImageStorage *)imageStorage {
    VVAsyncImageView *reuseImageView = [self _dequeueReusableImageContainerWithIdentifier:imageStorage.identifier];
    if (!reuseImageView) {
        reuseImageView = [[VVAsyncImageView alloc] initWithFrame:CGRectZero];
        reuseImageView.identifier = imageStorage.identifier;
        [self addSubview:reuseImageView];
    }

    reuseImageView.backgroundColor = imageStorage.backgroundColor;
    reuseImageView.displayAsynchronously = self.displaysAsynchronously;
    reuseImageView.contentMode = imageStorage.contentMode;
    reuseImageView.frame = imageStorage.frame;
    reuseImageView.hidden = NO;
    [self.imageContainers addObject:reuseImageView];
    return reuseImageView;
}

- (VVAsyncImageView *)_dequeueReusableImageContainerWithIdentifier:(NSString *)identifier {
    for (VVAsyncImageView *asyncImageView in self.reusePool) {
        if ([asyncImageView.identifier isEqualToString:identifier]) {
            [self.reusePool removeObject:asyncImageView];
            return asyncImageView;
        }
    }
    return nil;
}


#pragma mark - Display

- (VVAsyncDisplayTransaction *)asyncDisplayTransaction {

    VVAsyncDisplayTransaction *transaction = [[VVAsyncDisplayTransaction alloc] init];

    //将要显示内容
    transaction.willDisplayBlock = ^(CALayer *layer) {
        //先移除之前的附件Views
        for (VVTextStorage *textStorage in self.layout.textStorages) {
            [textStorage.textLayout removeAttachmentFromSuperViewOrLayer];
        }
    };

    //正在显示内容
    transaction.displayBlock = ^(CALayer *layer, CGContextRef context, CGSize size, VVAsyncDisplayIsCanclledBlock isCancelledBlock) {
        [self _drawStoragesInContext:context inCancelled:isCancelledBlock layer:layer size:size];
    };

    //结束显示内容
    transaction.didDisplayBlock = ^(CALayer *layer, BOOL finished) {
        if (!finished) {
            // 先移除之前的附件Views
            for (VVTextStorage *textStorage in self.layout.textStorages) {
                [textStorage.textLayout removeAttachmentFromSuperViewOrLayer];
            }
        }
    };

    return transaction;
}

- (void)_drawStoragesInContext:(CGContextRef)context inCancelled:(VVAsyncDisplayIsCanclledBlock)isCancelledBlock layer:(CALayer *)layer size:(CGSize)size {
    if ([self.delegate respondsToSelector:@selector(extraAsyncDisplayIncontext:size:isCancelled:)]) {
        if (isCancelledBlock()) {
            return;
        }

        // 这个代理方法调用需要用户额外绘制的内容
        [self.delegate extraAsyncDisplayIncontext:context size:size isCancelled:isCancelledBlock];
    }

    // 直接绘制在VVAsyncDisplayView上
    for (VVImageStorage *imageStorage in self.layout.imageStorages) {
        if (isCancelledBlock()) {
            return;
        }

        [imageStorage vv_drawInContext:context isCancelled:isCancelledBlock];
    }

    // 绘制文字内容
    for (VVTextStorage *textStorage in self.layout.textStorages) {
        [textStorage.textLayout drawIncontext:context
                                         size:CGSizeZero
                                        point:textStorage.frame.origin
                                containerView:self
                               containerLayer:layer
                                  isCancelled:isCancelledBlock];
    }

    //绘制高亮内容
    if (_showingHighlight && _highlight) {
        for (NSValue *rectValue in _highlight.positions) {
            if (isCancelledBlock()) {
                return;
            }

            CGRect rect = [rectValue CGRectValue];
            CGRect adjustRect = CGRectMake(rect.origin.x + _highlightAdjustPoint.x, rect.origin.y + _highlightAdjustPoint.y, rect.size.width, rect.size.height);
            UIBezierPath *beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect cornerRadius:2.0f];
            [_highlight.hightlightColor setFill];
            [beizerPath fill];
        }
    }
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL found = NO;

    if (_highlight) {
        _highlight = nil;
        if (_showingHighlight) {
            [self _hideHighlight];
        }
    }

    for (VVTextStorage *textStorage in self.layout.textStorages) {
        if (!_highlight) {
            VVTextHighlight *hightlight = [self _searchTextHighlightWithType:NO textStorage:textStorage touchPoint:touchPoint];
            if (hightlight) {
                _highlight = hightlight;
                _highlightAdjustPoint = textStorage.frame.origin;
                [self _showHighligt];
                found = YES;
                break;
            }
        }
    }

    if (!found) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL found = NO;

    if (!_highlight) {
        [super touchesMoved:touches withEvent:event];
        return;
    }

    for (VVTextStorage *textStorage in self.layout.textStorages) {
        VVTextHighlight *hightlight = [self _searchTextHighlightWithType:NO textStorage:textStorage touchPoint:touchPoint];
        if (hightlight == _highlight) {
            if (!_showingHighlight) {
                [self _showHighligt];
                found = YES;
            }
        } else {
            if (_showingHighlight) {
                [self _hideHighlight];
                found = NO;
            }
        }
        break;
    }

    if (!found) {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    BOOL found = NO;
    for (VVImageStorage *imageStorage in self.layout.imageStorages) {
        if (CGRectContainsPoint(imageStorage.frame, touchPoint)) {
            if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(vvAsyncDisplayView:didCilickedImageStorage:touch:)] &&
                    [self.delegate conformsToProtocol:@protocol(VVAsyncDisplayViewDelegate)]) {
                [self.delegate vvAsyncDisplayView:self didCilickedImageStorage:imageStorage touch:touch];
            }
            found = YES;
            break;
        }
    }

    if (!_highlight && !found) {
        [super touchesEnded:touches withEvent:event];
        return;
    }

    for (VVTextStorage *textStorage in self.layout.textStorages) {
        VVTextHighlight *hightlight = [self _searchTextHighlightWithType:NO textStorage:textStorage touchPoint:touchPoint];
        if (hightlight == _highlight) {
            if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(vvAsyncDisplayView:didCilickedTextStorage:linkdata:)] &&
                    [self.delegate conformsToProtocol:@protocol(VVAsyncDisplayViewDelegate)]) {
                [self.delegate vvAsyncDisplayView:self didCilickedTextStorage:textStorage linkdata:_highlight.content];
            }
            found = YES;
            break;
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.15f * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
                _highlight = nil;
                [self _hideHighlight];
            });

    if (!found) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)longPressGestureRecognizer {

    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint point = [longPressGestureRecognizer locationInView:self];
            _touchBeganPoint = point;
            for (VVTextStorage *textStorage in self.layout.textStorages) {
                VVTextHighlight *hightlight = [self _searchTextHighlightWithType:YES textStorage:textStorage touchPoint:_touchBeganPoint];

                if (hightlight.type == VVTextHighLightTypeLongPress) {
                    if (_highlight != hightlight) {
                        _highlight = hightlight;
                        _highlightAdjustPoint = textStorage.frame.origin;
                        [self _showHighligt];
                        break;
                    }
                }
            }
        }
            break;

        case UIGestureRecognizerStateEnded: {
            if (_highlight.type != VVTextHighLightTypeLongPress) {
                _highlight = nil;
                [self _hideHighlight];
            }
            for (VVTextStorage *textStorage in self.layout.textStorages) {
                VVTextHighlight *hightlight = [self _searchTextHighlightWithType:YES textStorage:textStorage touchPoint:_touchBeganPoint];
                if (_highlight && hightlight == _highlight) {
                    if (self.delegate &&
                            [self.delegate respondsToSelector:@selector(vvAsyncDisplayView:didLongpressedTextStorage:linkdata:)] &&
                            [self.delegate conformsToProtocol:@protocol(VVAsyncDisplayViewDelegate)]) {
                        [self.delegate vvAsyncDisplayView:self didLongpressedTextStorage:textStorage linkdata:_highlight.content];
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}


- (VVTextHighlight *)_searchTextHighlightWithType:(BOOL)isLongPress
                                      textStorage:(VVTextStorage *)textStorage
                                       touchPoint:(CGPoint)touchPoint {

    if (![textStorage isKindOfClass:[VVTextStorage class]]) {
        return nil;
    }

    CGPoint adjustPosition = textStorage.frame.origin;
    VVTextHighlight *needShow = nil;
    for (VVTextHighlight *one in textStorage.textLayout.textHighlights) {
        for (NSValue *value in one.positions) {
            CGRect rect = [value CGRectValue];
            CGRect adjustRect = CGRectMake(rect.origin.x + adjustPosition.x, rect.origin.y + adjustPosition.y, rect.size.width, rect.size.height);
            if (CGRectContainsPoint(adjustRect, touchPoint)) {
                if (!isLongPress) {
                    if (one.type == VVTextHighLightTypeNormal) {
                        return one;
                    } else if (one.type == VVTextHighLightTypeLongPress) {
                        continue;
                    }
                    needShow = one;
                } else {
                    if (one.type == VVTextHighLightTypeLongPress) {
                        return one;
                    }
                    continue;
                }
            }
        }
    }
    return needShow;
}

- (void)_showHighligt {
    _showingHighlight = YES;
    [(VVAsyncDisplayLayer *) self.layer displayImmediately];
}

- (void)_hideHighlight {
    _showingHighlight = NO;
    [(VVAsyncDisplayLayer *) self.layer displayImmediately];
}


- (void)removeHighlightIfNeed {
    if (!_highlight) {
        return;
    }
    _highlightAdjustPoint = CGPointZero;
    _touchBeganPoint = CGPointZero;
    _showingHighlight = NO;
    _highlight = nil;
    [(VVAsyncDisplayLayer *) self.layer displayImmediately];
}

#pragma mark - Getter

+ (Class)layerClass {
    return [VVAsyncDisplayLayer class];
}

- (NSMutableArray *)imageContainers {
    if (_imageContainers) {
        return _imageContainers;
    }
    _imageContainers = [[NSMutableArray alloc] init];
    return _imageContainers;
}

- (NSMutableArray *)reusePool {
    if (_reusePool) {
        return _reusePool;
    }
    _reusePool = [[NSMutableArray alloc] init];
    return _reusePool;
}

- (UILongPressGestureRecognizer *)longPressGesture {
    if (_longPressGesture) {
        return _longPressGesture;
    }
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    _longPressGesture.minimumPressDuration = 0.5f;
    return _longPressGesture;
}

#pragma mark - Setter

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    if (_displaysAsynchronously != displaysAsynchronously) {
        _displaysAsynchronously = displaysAsynchronously;
        [(VVAsyncDisplayLayer *) self.layer setDisplaysAsynchronously:_displaysAsynchronously];
    }
}

@end
