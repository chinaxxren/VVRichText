
#import "VVTextParser.h"
#import "VVImage.h"
#import "VVImageView.h"

static inline NSRegularExpression *EmojiRegularExpression();

static inline NSRegularExpression *URLRegularExpression();

static inline NSRegularExpression *AccountRegularExpression();

static inline NSRegularExpression *TopicRegularExpression();

static inline NSRegularExpression *TelRegularExpression();

static inline NSBundle *MotionQQBundle();

static NSString *EMOJI_REGULAR = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
static NSString *ACCOUNT_REGULAR = @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}";
static NSString *TOPIC_REGULAR = @"#[^#]+#";
static NSString *TEL_REGULAR = @"\\d{11}";
static NSString *URL_REGULAR = @"[a-zA-z]+://[^\\s]*";

@implementation VVTextParser

+ (void)emojiRegular:(NSString *)str {
    if (!str) {
        return;
    }

    EMOJI_REGULAR = str;
}

+ (void)accountRegular:(NSString *)str {
    if (!str) {
        return;
    }

    ACCOUNT_REGULAR = str;
}

+ (void)topicRegular:(NSString *)str {
    if (!str) {
        return;
    }

    TOPIC_REGULAR = str;
}

+ (void)telRegular:(NSString *)str {
    if (!str) {
        return;
    }

    TEL_REGULAR = str;
}

+ (void)urlRegular:(NSString *)str {
    if (!str) {
        return;
    }

    URL_REGULAR = str;
}

+ (void)parseGeneralEmojiWithTextStorage:(VVTextStorage *)textStorage {
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
                                      NSString *content = [text substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
                                      if (textStorage.text.length >= range.location + range.length) {
                                          [textStorage vv_replaceTextWithImage:[VVImage imageNamed:content]
                                                                   contentMode:UIViewContentModeScaleAspectFill
                                                                     imageSize:CGSizeMake(14, 14)
                                                                     alignment:VVTextAttachAlignmentTop
                                                                         range:range];
                                      }
                                  }];
}

+ (void)parseGifEmojiWithTextStorage:(VVTextStorage *)textStorage {
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
                                      NSString *content = [text substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
                                      if (textStorage.text.length >= range.location + range.length) {
                                          NSString *motionPath = [MotionQQBundle() pathForResource:content ofType:@"gif"];
                                          VVImageView *asyncImageView = [[VVImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
                                          asyncImageView.image = [VVImage imageWithContentsOfFile:motionPath];
                                          [textStorage vv_replaceTextWithView:asyncImageView
                                                                  contentMode:UIViewContentModeScaleAspectFill
                                                                         size:asyncImageView.frame.size
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
                initWithPattern:EMOJI_REGULAR
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
                initWithPattern:URL_REGULAR
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
                initWithPattern:ACCOUNT_REGULAR
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
                initWithPattern:TOPIC_REGULAR
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
                initWithPattern:TEL_REGULAR
                        options:NSRegularExpressionCaseInsensitive
                          error:nil];
    });
    return _TelRegularExpression;
}

static inline NSBundle *MotionQQBundle() {
    static NSBundle *_Bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"EmoticonQQ.bundle"];
        _Bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return _Bundle;
}

