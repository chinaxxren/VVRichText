
#import <UIKit/UIKit.h>

#import "VVWidget.h"
#import "VVTextWidget.h"
#import "VVImageWidget.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VVWidgetCollectProtocol <NSObject>

/**
 *  添加一个VVWidget对象
 *
 *  @param widget 一个VVWidget对象
 */
- (void)addWidget:(VVWidget *)widget;

/**
 *  添加一个包含VVWidget对象的数组的所有元素到VVLayout
 *
 *  @param widgets 一个包含VVWidget对象的数组
 */
- (void)addWidgets:(NSArray <VVWidget *> *)widgets;

/**
 *  移除一个VVWidget对象
 *
 *  @param widget 一个VVWidget对象
 */
- (void)removeWidget:(VVWidget *)widget;

/**
 *  移除一个包含VVWidget对象的数组的所有元素
 *
 *  @param widgets 一个包含VVWidget对象的数组
 */
- (void)removeWidgets:(NSArray <VVWidget *> *)widgets;

/**
 *  获取到一个建议的高度，主要用于UITabelViewCell的高度设定。
 *  你可以在UITableVeiw的代理方法中直接返回这个高度，来方便的动态设定Cell高度
 *
 *  @param bottomMargin 距离底部的间距
 *
 *  @return 建议的高度
 */
- (CGFloat)suggestHeightWithBottomMargin:(CGFloat)bottomMargin;


/**
 *  获取包含VVTextWidget的数组
 */
- (NSMutableArray<VVTextWidget *> *)textWidgets;

/**
 *  获取包含VVImageWidget的数组
 */
- (NSMutableArray<VVImageWidget *> *)imageWidgets;


/**
 *  获取包含所有的VVWidget的数组
 */
- (NSMutableArray<VVWidget *> *)totalWidgets;


@end

NS_ASSUME_NONNULL_END

/**
 * (View Object) VVRichText的布局模型。其中包含了VVWidget及其子类的对象。
 */
@interface VVWidgetCollect : VVIdentifier <VVWidgetCollectProtocol>

@property(nonatomic, assign) CGFloat height;

@end
