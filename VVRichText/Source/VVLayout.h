
#import <UIKit/UIKit.h>
#import "VVStorage.h"
#import "VVTextStorage.h"
#import "VVImageStorage.h"


@protocol VVLayoutProtocol <NSObject>

/**
 *  添加一个VVStorage对象
 *
 *  @param storage 一个VVStorage对象
 */
- (void)addStorage:(nullable VVStorage *)storage;

/**
 *  添加一个包含VVStorage对象的数组的所有元素到VVLayout
 *
 *  @param storages 一个包含VVStorage对象的数组
 */
- (void)addStorages:(nullable NSArray <VVStorage *> *)storages;

/**
 *  移除一个VVStorage对象
 *
 *  @param storage 一个VVStorage对象
 */
- (void)removeStorage:(nullable VVStorage *)storage;

/**
 *  移除一个包含VVStorage对象的数组的所有元素
 *
 *  @param storages 一个包含VVStorage对象的数组
 */
- (void)removeStorages:(nullable NSArray <VVStorage *> *)storages;

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
 *  获取包含VVTextStorage的数组
 */
- (nullable NSMutableArray<VVTextStorage *> *)textStorages;

/**
 *  获取包含VVImageStorage的数组
 */
- (nullable NSMutableArray<VVImageStorage *> *)imageStorages;


/**
 *  获取包含所有的VVStorage的数组
 */
- (nullable NSMutableArray<VVStorage *> *)totalStorages;


@end


/**
 *  VVRichText的布局模型。其中包含了VVStorage及其子类的对象。
 */
@interface VVLayout : NSObject <VVLayoutProtocol, NSCoding>

- (BOOL)isEqual:(nullable id)other;

- (BOOL)isEqualToLayout:(nullable VVLayout *)layout;

- (NSUInteger)hash;


@end
