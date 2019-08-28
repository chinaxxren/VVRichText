
#import <UIKit/UIKit.h>
#import "LikeButton.h"
#import "StatusDto.h"


@interface MenuView : UIView

@property (nonatomic,strong) LikeButton* likeButton;
@property (nonatomic,strong) UIButton* commentButton;
@property (nonatomic,strong) StatusDto* statusModel;

- (void)clickedMenu;
- (void)menuShow;
- (void)menuHide;

@end
