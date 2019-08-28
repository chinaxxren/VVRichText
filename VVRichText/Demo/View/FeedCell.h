

#import <UIKit/UIKit.h>

#import "FeedWidgetCollect.h"
#import "VVRichText.h"

#define Feed_Cell @"FeedCell"

@interface FeedCell : UITableViewCell

@property(nonatomic, assign) BOOL asynDisplay;//是否异步绘制
@property(nonatomic, strong) FeedWidgetCollect *widgetCollect;
@property(nonatomic, strong) NSIndexPath *indexPath;
@property(nonatomic, copy) void (^clickedImageCallback)(FeedCell *cell, NSInteger imageIndex);
@property(nonatomic, copy) void (^clickedLikeButtonCallback)(FeedCell *cell, BOOL isLike);
@property(nonatomic, copy) void (^clickedAvatarCallback)(FeedCell *cell);
@property(nonatomic, copy) void (^clickedReCommentCallback)(FeedCell *cell, CommentModel *model);
@property(nonatomic, copy) void (^clickedCommentButtonCallback)(FeedCell *cell);
@property(nonatomic, copy) void (^clickedOpenCellCallback)(FeedCell *cell);
@property(nonatomic, copy) void (^clickedCloseCellCallback)(FeedCell *cell);

@end


