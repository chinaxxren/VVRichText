
#import <Foundation/Foundation.h>
#import "VVTextStorage.h"

@interface VVTextParser : NSObject

/**
*  解析表情替代为相应的普通图片
*  格式：text：@“hello,world~![微笑]”  ----> @"hello，world~！（[UIImage imageNamed:@“微笑”]）"
*  @param textStorage 需要解析的VVTextStorage对象
*/
+ (void)parseGeneralEmojiWithTextStorage:(VVTextStorage *)textStorage;

/**
*  解析表情替代为相应的Gif图片
*  格式：text：@“hello,world~![微笑]”  ----> @"hello，world~！（[UIImage imageNamed:@“微笑”]）"
*  @param textStorage 需要解析的VVTextStorage对象
*/
+ (void)parseGifEmojiWithTextStorage:(VVTextStorage *)textStorage;


/**
 *  解析HTTP(s):// 并添加链接
 *
 *  @param textStorage   需要解析的VVTextStorage对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseHttpURLWithTextStorage:(VVTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor;


/**
 *  解析 @用户 并添加链接
 *
 *  @param textStorage   需要解析的VVTextStorage对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseAccountWithTextStorage:(VVTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor;


/**
 *  解析 #主题# 并添加链接
 *
 *  @param textStorage   需要解析的VVTextStorage对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseTopicWithVVTextStorage:(VVTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor;


/**
 *  解析 手机号码 并添加链接
 *
 *  @param textStorage   需要解析的VVTextStorage对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseTelWithVVTextStorage:(VVTextStorage *)textStorage
                        linkColor:(UIColor *)linkColor
                   highlightColor:(UIColor *)higlightColor;


@end
