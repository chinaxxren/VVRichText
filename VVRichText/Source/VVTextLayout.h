
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "VVTextContainer.h"
#import "VVTextAttachment.h"
#import "VVRichTextDefine.h"


@class VVTextLine;

/**
 *  文本布局模型，对CoreText的封装
 */
@interface VVTextLayout : NSObject <NSCoding>

@property(nonatomic, strong, readonly) VVTextContainer *container; //文本容器
@property(nonatomic, strong, readonly) NSAttributedString *text; //文本
@property(nonatomic, assign, readonly) CTFrameRef ctFrame; //Coretext中的CTFrameRef对象
@property(nonatomic, assign, readonly) CTFramesetterRef ctFrameSetter; ///Coretext中的CTFramesetterRef对象
@property(nonatomic, assign, readonly) NSInteger numberOfLines; //实际行数
@property(nonatomic, assign) NSInteger maxNumberOfLines; //行数限制，如果是0，则不限制行数，默认是0
@property(nonatomic, assign, readonly) CGPathRef cgPath; //文本绘制的路径
@property(nonatomic, assign, readonly) CGRect cgPathBox; //文本容器的边框
@property(nonatomic, assign, readonly) CGSize suggestSize; //建议的绘制大小
@property(nonatomic, assign, readonly) CGRect textBoundingRect; //文本边框
@property(nonatomic, assign, readonly) CGSize textBoundingSize; //文本边框的大小
@property(nonatomic, strong, readonly) NSArray<VVTextLine *> *linesArray; //包含VVTextLine的数组
@property(nonatomic, strong, readonly) NSArray<VVTextAttachment *> *attachments; //包含文本附件的数组
@property(nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRanges; //包含文本附件在文本中位置信息的数组
@property(nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRects; //包含文本附件在VVAsyncView上位置CGRect信息的数组
@property(nonatomic, strong, readonly) NSSet<id> *attachmentContentsSet; //附件内容的集合
@property(nonatomic, strong, readonly) NSArray<VVTextHighlight *> *textHighlights; //一个包含文本链接的信息的数组
@property(nonatomic, strong, readonly) NSArray<VVTextBackgroundColor *> *backgroundColors; //一个包含文本背景颜色的信息的数组
@property(nonatomic, strong, readonly) NSArray<VVTextBoundingStroke *> *boudingStrokes; //一个包含文本边框描边信息的数组
@property(nonatomic, assign, getter = isNeedDebugDraw) BOOL needDebugDraw; //是否开启调试绘制模式,默认是NO
@property(nonatomic, assign, getter = isNeedAttachmentDraw) BOOL needAttachmentDraw; //是否需要绘制附件
@property(nonatomic, assign, getter = isNeedTextBackgroundColorDraw) BOOL needTextBackgroundColorDraw; //是否需要绘制文本背景颜色
@property(nonatomic, assign, getter = isNeedStrokeDraw) BOOL needStrokeDraw; //是否需要描边绘制
@property(nonatomic, assign, getter = isNeedBoudingStrokeDraw) BOOL needBoudingStrokeDraw; //是否需要绘制文本边框描边
@property(nonatomic, assign, readonly) BOOL needTruncation; //是否折叠

/**
 *  构造方法
 *
 *  @param container VVTextContainer
 *  @param text      NSAttributedString
 *
 *  @return VVTextLayout实例
 */
+ (VVTextLayout *)vv_layoutWithContainer:(VVTextContainer *)container text:(NSAttributedString *)text;


/**
 *  绘制文本
 *
 *  @param context        CGContextRef对象，绘制上下文
 *  @param size           绘制范围的大小
 *  @param point          在VVAsyncView中的绘制起始点CGPoint
 *  @param containerView  绘制文本的容器UIView对象
 *  @param containerLayer 绘制文本的容器UIView对象的CALayer对象(.layer)
 *  @param isCancelld     是否取消绘制
 */

- (void)vv_drawIncontext:(CGContextRef)context
                    size:(CGSize)size
                   point:(CGPoint)point
           containerView:(UIView *)containerView
          containerLayer:(CALayer *)containerLayer
             isCancelled:(VVAsyncIsCanclledBlock)isCancelld;


/**
 *  将文本附件从UIView或CALayer上移除，在即将开始绘制时调用
 */
- (void)vv_removeAttachmentFromSuperViewOrLayer;

@end
