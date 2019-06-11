
#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic,copy) NSString* from;
@property (nonatomic,copy) NSString* to;
@property (nonatomic,copy) NSString* content;
@property (nonatomic,assign) NSInteger index;

@end
