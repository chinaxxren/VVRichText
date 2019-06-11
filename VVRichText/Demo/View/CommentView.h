
#import <UIKit/UIKit.h>
#import "AutoFitSizeTextView.h"


typedef void(^PressSendBlock)(NSString * content);

@interface CommentView : UIView<AutoFitSizeTextViewDelegate>

@property (nonatomic,strong) AutoFitSizeTextView* textView;
@property (nonatomic,copy) NSString* placeHolder;
@property (nonatomic,copy) PressSendBlock sendBlock;


- (id)initWithFrame:(CGRect)frame sendBlock:(PressSendBlock)sendBlock;

@end
