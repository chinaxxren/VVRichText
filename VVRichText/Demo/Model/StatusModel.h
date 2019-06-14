

#import <Foundation/Foundation.h>
#import "CommentModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface StatusModel : NSObject <NSCopying>

@property (nonatomic,copy) NSString* type;
@property (nonatomic,strong) NSURL* avatar;
@property (nonatomic,copy) NSString* content;
@property (nonatomic,copy) NSString* detail;
@property (nonatomic,strong) NSDate* date;
@property (nonatomic,copy) NSArray* imgs;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,strong) NSNumber* statusID;
@property (nonatomic,copy) NSArray* commentList;
@property (nonatomic,copy) NSArray* likeList;
@property (nonatomic,assign) BOOL isLike;
@property (nonatomic,copy) NSArray* thumbnail;
@property (nonatomic,assign) BOOL isExpend;

- (StatusModel *)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
