
#import <UIKit/UIKit.h>


@class AutoFitSizeTextView;

@protocol AutoFitSizeTextViewDelegate <NSObject>

@optional

- (void)textView:(AutoFitSizeTextView *)textView heightChanged:(NSInteger)height;

@end

@interface AutoFitSizeTextView : UITextView


@property (nonatomic,weak) id <AutoFitSizeTextViewDelegate> fitSizeDelegate;

@end
