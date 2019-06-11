
#import <UIKit/UIKit.h>

typedef void(^likeActionBlock)(BOOL isSelectd);

@interface LikeButton : UIButton

- (void)likeButtonAnimationCompletion:(likeActionBlock)completion;

@end
