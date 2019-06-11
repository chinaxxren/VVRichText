
#import "ImageDemoTableViewCell.h"


@interface ImageDemoTableViewCell ()

@property (nonatomic,strong) VVAsyncDisplayView* displayView;

@end


@implementation ImageDemoTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.displayView = [[VVAsyncDisplayView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.displayView];
        
    }
    return self ;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.displayView.frame = self.bounds;
}

- (void)setLayout:(VVLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
        
        self.displayView.layout = self.layout;
    }
}

@end
