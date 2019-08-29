

#import "VVWidgetCollect.h"
#import "StatusDto.h"

#define MESSAGE_TYPE_IMAGE @"image"
#define MESSAGE_TYPE_WEBSITE @"website"
#define MESSAGE_TYPE_VIDEO @"video"
#define AVATAR_IDENTIFIER @"avatar"
#define IMAGE_IDENTIFIER @"image"
#define WEBSITE_COVER_IDENTIFIER @"cover"

@interface FeedWidgetCollect : VVWidgetCollect

@property(nonatomic, strong) StatusDto *statusModel;
@property(nonatomic, assign) CGRect lineRect;
@property(nonatomic, assign) CGRect menuPosition;
@property(nonatomic, assign) CGRect commentBgPosition;
@property(nonatomic, assign) CGRect avatarPosition;
@property(nonatomic, assign) CGRect websitePosition;
@property(nonatomic, copy) NSArray *imagePostions;

- (id)initWithStatusModel:(StatusDto *)stautsModel index:(NSInteger)index dateFormatter:(NSDateFormatter *)dateFormatter;

@end
