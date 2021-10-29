

#import "VVWidget.h"

#import "VVTextLayout.h"
#import "VVAsynLayer.h"

/***  附件的对齐方式  ***/
typedef NS_ENUM(NSUInteger, VVTextAttachAlignment) {
    VVTextAttachAlignmentCenter,//attachment居中显示
    VVTextAttachAlignmentTop,//attachment的底部与baseline对齐
    VVTextAttachAlignmentBottom,//attachment的顶部与baseline对齐
};

/*** Text绘制方式  ***/
typedef NS_ENUM(NSUInteger, VVTextDrawMode) {
    VVTextDrawModeFill,//填充方式绘制
    VVTextDrawModeStroke,//描边方式绘制
};

/**
 *  文本绘制的数据模型
 */
@interface VVTextWidget : VVWidget

@property(nonatomic, strong, readonly) VVTextLayout *textLayout;//文本布局模型
@property(nonatomic, copy) NSString *text;//文本
@property(nonatomic, strong) NSMutableAttributedString *attributedText;//属性文本
@property(nonatomic, strong) UIColor *textColor;//文本颜色
@property(nonatomic, strong) UIColor *textBackgroundColor;//文本的背景颜色
@property(nonatomic, strong) UIColor *textBoundingStrokeColor;//文本外边框描边
@property(nonatomic, strong) UIFont *font;//字体
@property(nonatomic, assign) CGFloat linespacing;//行间距
@property(nonatomic, assign) unichar characterSpacing;//字间距
@property(nonatomic, assign) NSTextAlignment textAlignment;//水平对齐方式，默认是NSTextAlignmentLeft
@property(nonatomic, assign) VVTextVericalAlignment vericalAlignment;//垂直对齐方式，默认是TOP
@property(nonatomic, assign) NSUnderlineStyle underlineStyle;//下划线样式
@property(nonatomic, strong) UIColor *underlineColor;//下划线颜色
@property(nonatomic, assign) NSLineBreakMode lineBreakMode;//换行模式
@property(nonatomic, assign) VVTextDrawMode textDrawMode;//绘制模式
@property(nonatomic, strong) UIColor *strokeColor;//描边颜色
@property(nonatomic, assign) CGFloat strokeWidth;//描边宽度
@property(nonatomic, assign, readonly) CGSize suggestSize;//建议的绘制大小
@property(nonatomic, assign) NSUInteger maxNumberOfLines;//最大行数限制
@property(nonatomic, assign, readonly) NSInteger numberOfLines;//文本的实际行数
@property(nonatomic, assign) BOOL needDebugDraw;//是否开启调试模式
@property(nonatomic, assign, readonly) BOOL isTruncation;//是否折叠


/**
 *  构造方法
 *
 *  @param frame 一个CGRect对象，包含位置信息
 *
 *  @return 一个 VVTextWidget对象
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  构造方法
 *
 *  @param attributedText 一个属性字符创
 *  @param frame          一个CGRect对象，包含位置信息
 *
 *  @return 一个 VVTextWidget对象
 */
+ (VVTextWidget *)vv_textWidgetWithText:(NSAttributedString *)attributedText frame:(CGRect)frame;

/**
 *  构造方法
 *
 *  @param textLayout 一个VVTextLayout对象
 *  @param frame      一个CGRect对象，包含位置信息
 *
 *  @return 一个 VVTextWidget对象
 */
+ (VVTextWidget *)vv_textWidgetWithTextLayout:(VVTextLayout *)textLayout frame:(CGRect)frame;


/**
 *  为整个文本添加点击事件
 *  如果两个点击事件重叠，会优先响应使用“- (void)vv_addLinkWithData:(id)data
                                                        range:(NSRange)range
                                                    linkColor:(UIColor *)linkColor
 *                                             highLightColor:(UIColor *)highLightColor;”
 *  这个方法添加的指定位置链接。
 *
 *  @param data           为点击事件附带的用户信息
 *  @param linkColor      链接的颜色
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)vv_addLinkForWholeTextWidgetWithData:(id)data
                                   linkColor:(UIColor *)linkColor
                              highLightColor:(UIColor *)highLightColor
__deprecated_msg("Please use 'vv_addLinkForWholeTextWidgetWithData:highLightColor:' instead");

/**
 *  为整个文本添加点击事件
 *  如果两个点击事件重叠，会优先响应使用“- (void)vv_addLinkWithData:(id)data
                                                    range:(NSRange)range
                                                    linkColor:(UIColor *)linkColor
 *                                             highLightColor:(UIColor *)highLightColor;”
 *  这个方法添加的指定位置链接。
 *
 *  @param data           为点击事件附带的用户信息
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)vv_addLinkForWholeTextWidgetWithData:(id)data
                              highLightColor:(UIColor *)highLightColor;


/**
 *  为指定位置的文本添加点击事件
 *
 *  @param data           为点击事件附带的用户信息
 *  @param range          需要添加链接的文本在VVTextWidget对象的text中所处的位置，一个NSRange型的结构体对象
 *  @param linkColor      链接的颜色
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)vv_addLinkWithData:(id)data
                     range:(NSRange)range
                 linkColor:(UIColor *)linkColor
            highLightColor:(UIColor *)highLightColor;


/**
 *  为整个文本添加长按事件
 *
 *  @param data           为点击事件附带的用户信息
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)vv_addLongPressActionWithData:(id)data
                       highLightColor:(UIColor *)highLightColor;


/**
 *  用本地图片替换掉指定位置的文字
 *
 *  @param image           一个UIImage对象
 *  @param contentMode     图片对象的contentMode
 *  @param size            图像的大小
 *  @param attachAlignment 对齐方式
 *  @param range           需要被替换的文本所处的位置
 */
- (void)vv_replaceTextWithImage:(UIImage *)image
                    contentMode:(UIViewContentMode)contentMode
                      imageSize:(CGSize)size
                      alignment:(VVTextAttachAlignment)attachAlignment
                          range:(NSRange)range;

/**
 *  用网络图片替换掉指定位置的文字
 *
 *  @param URL             一个NSURL对象，这个图片的URL
 *  @param contentMode     图片对象的contentMode
 *  @param size            图片的大小
 *  @param attachAlignment 对齐方式
 *  @param range           需要被替换的文本所处的位置
 */
- (void)vv_replaceTextWithImageURL:(NSURL *)URL
                       contentMode:(UIViewContentMode)contentMode
                         imageSize:(CGSize)size
                         alignment:(VVTextAttachAlignment)attachAlignment
                             range:(NSRange)range;


/**
 *  用UIView及其子类对象替换掉指定位置的文字
 *
 *  @param view            一个UIView对象
 *  @param contentMode     UIView对象的contentMode
 *  @param size            UIView对象的大小
 *  @param attachAlignment UIView对象的对齐方式
 *  @param range           需要被替换的文本所处的位置
 */
- (void)vv_replaceTextWithView:(UIView *)view
                   contentMode:(UIViewContentMode)contentMode
                          size:(CGSize)size
                     alignment:(VVTextAttachAlignment)attachAlignment
                         range:(NSRange)range;

/**
 *  在这个VVTextWidget对象的尾部拼接一个VVTextWidget对象
 *
 *  @param textWidget 一个VVTextWidget对象
 */
- (void)vv_appendTextWidget:(VVTextWidget *)textWidget;


/**
 *  建立布局,并且能获得当前的VVTextWidget的frame和bounds
 *  可以单独调用不必等到添加到VVWidgetCollect调用
 */
- (void)createLayout;

@end
