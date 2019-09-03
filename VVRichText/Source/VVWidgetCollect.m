
#import "VVWidgetCollect.h"

@interface VVWidgetCollect ()

@property(nonatomic, strong) NSMutableArray<VVTextWidget *> *textWidgets;
@property(nonatomic, strong) NSMutableArray<VVImageWidget *> *imageWidgets;
@property(nonatomic, strong) NSMutableArray<VVWidget *> *totalWidgets;

@end

@implementation VVWidgetCollect

- (void)addWidget:(VVWidget *)widget {
    if (!widget) {
        return;
    }

    if ([widget isMemberOfClass:[VVTextWidget class]]) {
        VVTextWidget *textWidget = (VVTextWidget *) widget;
        [textWidget createLayout];
        [self.textWidgets addObject:textWidget];
    } else if ([widget isMemberOfClass:[VVImageWidget class]]) {
        [self.imageWidgets addObject:(VVImageWidget *) widget];
    }

    [self.totalWidgets addObject:widget];
}

- (void)addWidgets:(NSArray <VVWidget *> *)widgets {
    if (!widgets) {
        return;
    }

    for (VVWidget *widget in widgets) {
        [self addWidget:widget];
    }

    [self.totalWidgets addObjectsFromArray:widgets];
}


- (void)removeWidget:(VVWidget *)widget {
    if (!widget) {
        return;
    }

    if ([widget isMemberOfClass:[VVTextWidget class]]) {
        if ([self.textWidgets containsObject:widget]) {
            [self.textWidgets removeObject:widget];
            [self.totalWidgets removeObject:widget];
        }
    } else if ([widget isMemberOfClass:[VVImageWidget class]]) {
        if ([self.imageWidgets containsObject:widget]) {
            [self.imageWidgets removeObject:widget];
            [self.totalWidgets removeObject:widget];
        }
    }
}

- (void)removeWidgets:(NSArray <VVWidget *> *)widgets {
    if (!widgets) {
        return;
    }

    for (VVWidget *widget in widgets) {
        [self removeWidget:widget];
    }
}

- (CGFloat)suggestHeightWithBottomMargin:(CGFloat)bottomMargin {
    CGFloat suggestHeight = 0.0f;
    for (VVWidget *widget in self.totalWidgets) {
        suggestHeight = suggestHeight > widget.bottom ? suggestHeight : widget.bottom;
    }

    return suggestHeight + bottomMargin;
}

#pragma mark - Getter

- (nullable NSMutableArray *)textWidgets {
    if (_textWidgets) {
        return _textWidgets;
    }

    _textWidgets = [NSMutableArray new];
    return _textWidgets;
}

- (nullable NSMutableArray *)imageWidgets {
    if (_imageWidgets) {
        return _imageWidgets;
    }

    _imageWidgets = [NSMutableArray new];
    return _imageWidgets;
}

- (nullable NSMutableArray *)totalWidgets {
    if (_totalWidgets) {
        return _totalWidgets;
    }

    _totalWidgets = [NSMutableArray new];
    return _totalWidgets;
}

@end
