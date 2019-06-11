
#import <UIKit/UIKit.h>
#import "LikeButton.h"
#import "StatusModel.h"


@interface MenuView : UIView

@property (nonatomic,strong) LikeButton* likeButton;
@property (nonatomic,strong) UIButton* commentButton;
@property (nonatomic,strong) StatusModel* statusModel;

- (void)clickedMenu;
- (void)menuShow;
- (void)menuHide;

@end
