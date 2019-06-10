/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/VVRichText 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/






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
