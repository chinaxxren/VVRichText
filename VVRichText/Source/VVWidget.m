
#import "VVWidget.h"

#import "VVRichTextUtils.h"

@interface VVWidget ()

@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat right;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign) CGFloat bottom;

@end

@implementation VVWidget

#pragma mark - Init

- (_Nonnull instancetype)initWithIdentifier:(NSString *_Nullable)identifier {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        [self _setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _setup];
    }

    return self;
}

- (void)_setup {
    self.tag = -1;
    self.clipsToBounds = NO;
    self.opaque = YES;
    self.hidden = NO;
    self.alpha = 1.0f;
    self.frame = CGRectZero;
    self.bounds = CGRectZero;
    self.cornerRadius = 0.0f;
    self.cornerBorderWidth = 0.0f;
    self.shadowColor = nil;
    self.shadowOpacity = 0.0f;
    self.shadowOffset = CGSizeZero;
    self.shadowRadius = 0.0f;
    self.contentsScale = [VVRichTextUtils contentsScale];
    self.contentMode = UIViewContentModeScaleToFill;
}

#pragma mark - Getter & Setter

- (void)setCenter:(CGPoint)center {
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width * 0.5f;
    frame.origin.y = center.y - frame.size.height * 0.5f;
    self.frame = frame;
}

- (void)setBounds:(CGRect)bounds {
    CGRect frame = self.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y, bounds.size.width, bounds.size.height);
    self.frame = frame;
}


- (CGRect)bounds {
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return self.frame.origin.x + self.width;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.height;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGPoint)center {
    return CGPointMake(self.frame.origin.x + self.frame.size.width * 0.5f,
            self.frame.origin.y + self.frame.size.height * 0.5f);
}

@end
