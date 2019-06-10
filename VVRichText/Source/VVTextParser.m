
#import "VVTextParser.h"

#define EmojiRegular @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
#define AccountRegular @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"
#define TopicRegular @"#[^#]+#"
#define TELRegular @"1[3|4|5|7|8][0-9]\\d{8}"
#define URLRegular @"[a-zA-z]+://[^\\s]*"


static inline NSRegularExpression *EmojiRegularExpression();

static inline NSRegularExpression *URLRegularExpression();

static inline NSRegularExpression *AccountRegularExpression();

static inline NSRegularExpression *TopicRegularExpression();

static inline NSRegularExpression *TelRegularExpression();


@implementation VVTextParser

+ (void)parseEmojiWithTextStorage:(VVTextStorage *)textStorage {
    NSString *text = textStorage.text;
    if (!text) {
        return;
    }
    NSArray *resultArray = [EmojiRegularExpression() matchesInString:text
                                                             options:0
                                                               range:NSMakeRange(0, text.length)];
    [resultArray enumerateObjectsWithOptions:NSEnumerationReverse
                                  usingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                      NSTextCheckingResult *match = resultArray[idx];
                                      NSRange range = [match range];
                                      NSString *content = [text substringWithRange:range];
                                      if (textStorage.text.length >= range.location + range.length) {
                                          [textStorage vv_replaceTextWithImage:[UIImage imageNamed:content]
                                                                   contentMode:UIViewContentModeScaleAspectFill
                                                                     imageSize:CGSizeMake(14, 14)
                                                                     alignment:VVTextAttachAlignmentTop
                                                                         range:range];
                                      }
                                  }];
}


+ (void)parseHttpURLWithTextStorage:(VVTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor {
    NSString *text = textStorage.text;
    if (!text) {
        return;
    }

    NSArray *resultArray = [URLRegularExpression() matchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0, text.length)];
    [resultArray enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull match, NSUInteger idx, BOOL *_Nonnull stop) {
        NSRange range = [match range];
        NSString *content = [text substringWithRange:range];
        if (textStorage.text.length >= range.location + range.length) {
            [textStorage vv_addLinkWithData:[NSString stringWithFormat:@"href://%@", content]
                                      range:range
                                  linkColor:linkColor
                             highLightColor:higlightColor];
        }
    }];
}


+ (void)parseAccountWithTextStorage:(VVTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor {
    NSString *text = textStorage.text;
    if (!text) {
        return;
    }
    NSArray *resultArray = [AccountRegularExpression() matchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, text.length)];
    [resultArray enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull match, NSUInteger idx, BOOL *_Nonnull stop) {
        NSRange range = [match range];
        NSString *content = [text substringWithRange:range];
        if (textStorage.text.length >= range.location + range.length) {
            [textStorage vv_addLinkWithData:[NSString stringWithFormat:@"user://%@", content]
                                      range:range
                                  linkColor:linkColor
                             highLightColor:higlightColor];
        }
    }];
}


+ (void)parseTopicWithVVTextStorage:(VVTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor {
    NSString *text = textStorage.text;
    if (!text) {
        return;
    }
    NSArray *resultArray = [TopicRegularExpression() matchesInString:text
                                                             options:0
                                                               range:NSMakeRange(0, text.length)];
    [resultArray enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull match, NSUInteger idx, BOOL *_Nonnull stop) {
        NSRange range = [match range];
        NSString *content = [text substringWithRange:range];
        if (textStorage.text.length >= range.location + range.length) {
            [textStorage vv_addLinkWithData:[NSString stringWithFormat:@"topic://%@", content]
                                      range:range
                                  linkColor:linkColor
                             highLightColor:higlightColor];
        }
    }];
}


+ (void)parseTelWithVVTextStorage:(VVTextStorage *)textStorage
                        linkColor:(UIColor *)linkColor
                   highlightColor:(UIColor *)higlightColor {
    NSString *text = textStorage.text;
    if (!text) {
        return;
    }
    NSArray *resultArray = [TelRegularExpression() matchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0, text.length)];
    [resultArray enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull match, NSUInteger idx, BOOL *_Nonnull stop) {
        NSRange range = [match range];
        NSString *content = [text substringWithRange:range];
        if (textStorage.text.length >= range.location + range.length) {
            [textStorage vv_addLinkWithData:[NSString stringWithFormat:@"tel://%@", content]
                                      range:range
                                  linkColor:linkColor
                             highLightColor:higlightColor];
        }
    }];
}

@end


static inline NSRegularExpression *EmojiRegularExpression() {
    static NSRegularExpression *_EmojiRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _EmojiRegularExpression = [[NSRegularExpression alloc]
                initWithPattern:EmojiRegular
                        options:NSRegularExpressionAnchorsMatchLines
                          error:nil];
    });
    return _EmojiRegularExpression;
}

static inline NSRegularExpression *URLRegularExpression() {
    static NSRegularExpression *_URLRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _URLRegularExpression = [[NSRegularExpression alloc]
                initWithPattern:URLRegular
                        options:NSRegularExpressionAnchorsMatchLines
                          error:nil];
    });
    return _URLRegularExpression;
}

static inline NSRegularExpression *AccountRegularExpression() {
    static NSRegularExpression *_AccountRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AccountRegularExpression = [[NSRegularExpression alloc]
                initWithPattern:AccountRegular
                        options:NSRegularExpressionAnchorsMatchLines
                          error:nil];
    });
    return _AccountRegularExpression;
}

static inline NSRegularExpression *TopicRegularExpression() {
    static NSRegularExpression *_TopicRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TopicRegularExpression = [[NSRegularExpression alloc]
                initWithPattern:TopicRegular
                        options:NSRegularExpressionCaseInsensitive
                          error:nil];
    });
    return _TopicRegularExpression;
}

static inline NSRegularExpression *TelRegularExpression() {
    static NSRegularExpression *_TelRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TelRegularExpression = [[NSRegularExpression alloc]
                initWithPattern:TELRegular
                        options:NSRegularExpressionCaseInsensitive
                          error:nil];
    });
    return _TelRegularExpression;
}

