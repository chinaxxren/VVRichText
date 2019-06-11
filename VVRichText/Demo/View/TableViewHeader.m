
#import "TableViewHeader.h"
#import "VVRichText.h"


@interface TableViewHeader ()

@property(nonatomic, strong) UIImageView *loadingView;

@end

@implementation TableViewHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        VVAsyncDisplayView *displayView =
                [[VVAsyncDisplayView alloc] initWithFrame:CGRectMake(0.0f, -100.0f, SCREEN_WIDTH, 350.0f)];
        [self addSubview:displayView];
        [self addSubview:self.loadingView];

        VVLayout *layout = [[VVLayout alloc] init];
        VVImageStorage *bg = [[VVImageStorage alloc] init];
        bg.contents = [NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"];
        bg.frame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, displayView.bounds.size.height);
        bg.clipsToBounds = YES;
        [layout addStorage:bg];

        VVImageStorage *avtar = [[VVImageStorage alloc] init];
        avtar.contents = [NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"];
        avtar.frame = CGRectMake(SCREEN_WIDTH - 90.0f, displayView.bounds.size.height - 40.0f, 80.0f, 80.0f);
        avtar.cornerRadius = 0.01f;
        avtar.cornerBorderColor = [UIColor whiteColor];
        avtar.cornerBorderWidth = 5.0f;
        [layout addStorage:avtar];


        displayView.layout = layout;
    }
    return self;
}


- (UIImageView *)loadingView {
    if (_loadingView) {
        return _loadingView;
    }
    _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, -70.0f, 25.0f, 25.0f)];
    _loadingView.contentMode = UIViewContentModeScaleAspectFill;
    _loadingView.image = [UIImage imageNamed:@"loading"];
    _loadingView.clipsToBounds = YES;
    _loadingView.backgroundColor = [UIColor clearColor];
    return _loadingView;
}

- (void)loadingViewAnimateWithScrollViewContentOffset:(CGFloat)offset {
    if (offset <= 0 && offset > -200.0f) {
        self.loadingView.transform = CGAffineTransformMakeRotation(offset * 0.1f);
    }
}

- (void)refreshingAnimateBegin {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.duration = 0.5f;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.fromValue = @0.0f;
    rotationAnimation.toValue = @(2 * M_PI);
    [self.loadingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimations"];
}

- (void)refreshingAnimateStop {
    [self.loadingView.layer removeAllAnimations];
}


@end
