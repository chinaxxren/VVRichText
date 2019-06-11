
#import <UIKit/UIKit.h>

@interface TableViewHeader : UIView

- (void)loadingViewAnimateWithScrollViewContentOffset:(CGFloat)offset;
- (void)refreshingAnimateBegin;
- (void)refreshingAnimateStop;

@end
