
#import <UIKit/UIKit.h>
#import <YYImage/YYAnimatedImageView.h>


@interface VVImageView : YYAnimatedImageView

/**
 *  一个标示符字符串，跟VVImageStorage中的同名属性对应.
 *  当VVAsyncImageView不需要时，会放入VVAsyncView的reusePool当中
 *  需要用到时，通过这个identifier为key去reusePool中取
 */
@property(nonatomic, copy) NSString *identifier;

@end
