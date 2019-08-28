
#import "TextViewCell.h"


@interface TextViewCell ()

@property(nonatomic, strong) VVAsynView *displayView;

@end

@implementation TextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.displayView = [[VVAsynView alloc] initWithFrame:CGRectZero];
        self.displayView.backgroundColor = [UIColor yellowColor];
        self.displayView.asynDisplay = YES;
        [self.contentView addSubview:self.displayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.displayView.frame = self.bounds;
}

- (void)setWidgetCollect:(VVWidgetCollect *)widgetCollect {
    if (_widgetCollect != widgetCollect) {
        _widgetCollect = widgetCollect;

        self.displayView.widgetCollect = self.widgetCollect;
    }
}

@end
