
#import "AutoFitSizeTextView.h"

@implementation AutoFitSizeTextView


- (void)setContentSize:(CGSize)contentSize {
    CGSize oriSize = self.contentSize;
    [super setContentSize:contentSize];
    if(oriSize.height != self.contentSize.height){
        CGRect newFrame = self.frame;
        newFrame.size.height = self.contentSize.height;
        self.frame = newFrame;
        if([self.fitSizeDelegate respondsToSelector:@selector(textView:heightChanged:)]){
            [self.fitSizeDelegate textView:self heightChanged:floorf(self.contentSize.height - oriSize.height)];
        }
    }
}


@end
