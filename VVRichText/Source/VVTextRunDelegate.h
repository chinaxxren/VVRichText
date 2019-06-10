
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

/**
 *  对CTRunDelegateRef的封装
 */
@interface VVTextRunDelegate : NSObject <NSCoding, NSMutableCopying, NSCopying>

@property(nullable, nonatomic, assign) CTRunDelegateRef CTRunDelegate; //CoreText中的CTRunDelegateRef
@property(nullable, nonatomic, strong) NSDictionary *userInfo; //自定义的一些信息
@property(nonatomic, assign) CGFloat ascent; //上部距离
@property(nonatomic, assign) CGFloat descent; //下部距离
@property(nonatomic, assign) CGFloat width; //宽度
@property(nonatomic, assign) CGFloat height; //高度

@end
