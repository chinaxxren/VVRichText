

#import "VVWidgetCollect.h"
#import "StatusModel.h"


#define MESSAGE_TYPE_IMAGE @"image"
#define MESSAGE_TYPE_WEBSITE @"website"
#define MESSAGE_TYPE_VIDEO @"video"
#define AVATAR_IDENTIFIER @"avatar"
#define IMAGE_IDENTIFIER @"image"
#define WEBSITE_COVER_IDENTIFIER @"cover"

@interface FeedWidgetCollect : VVWidgetCollect

@property(nonatomic, strong) StatusModel *statusModel;
@property(nonatomic, assign) CGRect lineRect;
@property(nonatomic, assign) CGRect menuPosition;
@property(nonatomic, assign) CGRect commentBgPosition;
@property(nonatomic, assign) CGRect avatarPosition;
@property(nonatomic, assign) CGRect websitePosition;
@property(nonatomic, copy) NSArray *imagePostions;

- (id)initWithStatusModel:(StatusModel *)stautsModel index:(NSInteger)index dateFormatter:(NSDateFormatter *)dateFormatter;

@end
