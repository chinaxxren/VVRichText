
#import <Foundation/Foundation.h>
#import "VVTextWidget.h"

@interface VVTextParser : NSObject

//改变默认正则值

+ (void)emojiRegular:(NSString *)str;

+ (void)accountRegular:(NSString *)str;

+ (void)topicRegular:(NSString *)str;

+ (void)telRegular:(NSString *)str;

+ (void)urlRegular:(NSString *)str;

/**
*  解析表情替代为相应的普通图片
*  格式：text：@“hello,world~![微笑]”  ----> @"hello，world~！（[UIImage imageNamed:@“微笑”]）"
*  @param textWidget 需要解析的VVTextWidget对象
*/
+ (void)parseGeneralEmojiWithTextWidget:(VVTextWidget *)textWidget;

/**
*  解析表情替代为相应的Gif图片
*  格式：text：@“hello,world~![微笑]”  ----> @"hello，world~！（[UIImage imageNamed:@“微笑”]）"
*  @param textWidget 需要解析的VVTextWidget对象
*/
+ (void)parseGifEmojiWithTextWidget:(VVTextWidget *)textWidget;


/**
 *  解析HTTP(s):// 并添加链接
 *
 *  @param textWidget   需要解析的VVTextWidget对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseHttpURLWithTextWidget:(VVTextWidget *)textWidget
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor;


/**
 *  解析 @用户 并添加链接
 *
 *  @param textWidget   需要解析的VVTextWidget对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseAccountWithTextWidget:(VVTextWidget *)textWidget
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor;


/**
 *  解析 #主题# 并添加链接
 *
 *  @param textWidget   需要解析的VVTextWidget对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseTopicWithVVTextWidget:(VVTextWidget *)textWidget
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor;


/**
 *  解析 手机号码 并添加链接
 *
 *  @param textWidget   需要解析的VVTextWidget对象
 *  @param linkColor     链接文本颜色
 *  @param higlightColor 链接点击时高亮颜色
 */
+ (void)parseTelWithVVTextWidget:(VVTextWidget *)textWidget
                       linkColor:(UIColor *)linkColor
                  highlightColor:(UIColor *)higlightColor;


@end
