

#import <UIKit/UIKit.h>


/**
 *  垂直方向对齐方式
 */
typedef NS_ENUM(NSUInteger, VVTextVericalAlignment) {
    VVTextVericalAlignmentTop, // 顶部对齐
    VVTextVericalAlignmentCenter, // 居中对齐
    VVTextVericalAlignmentBottom // 底部对齐
};


/**
 *  文本容器，包含文本绘制的范围大小、路径、会edgeInsets等信息
 */
@interface VVTextContainer : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, assign) VVTextVericalAlignment vericalAlignment;//垂直对齐方式，默认是TOP
@property(nonatomic, assign, readonly) CGSize size;//容器的大小
@property(nonatomic, strong, readonly) UIBezierPath *path;//容器的路径
@property(nonatomic, assign, readonly) UIEdgeInsets edgeInsets;//边缘内嵌大小
@property(nonatomic, assign) NSInteger maxNumberOfLines;//最大行数限制

/**
 *  构造方法
 *
 *  @param size 容器大小
 *
 *  @return 一个VVTextContrainer对象
 */
+ (id)vv_textContainerWithSize:(CGSize)size;

/**
 *  构造方法
 *
 *  @param size       容器大小
 *  @param edgeInsets 边缘内嵌大小
 *
 *  @return 一个VVTextContrainer对象
 */
+ (id)vv_textContainerWithSize:(CGSize)size edgeInsets:(UIEdgeInsets)edgeInsets;

/**
 *  容器路径的行宽
 *
 *  @return 路径的行宽
 */
- (CGFloat)vv_pathLineWidth;


@end
