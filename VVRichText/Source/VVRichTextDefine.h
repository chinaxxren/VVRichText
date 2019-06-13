
#ifndef VVRichTextDefine_h
#define VVRichTextDefine_h

//屏幕宽
#ifndef VV_SCREEN_WIDTH
#define VV_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif

//屏幕高
#ifndef VV_SCREEN_HEIGHT
#define VV_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif

//通过RGBA返回UIColor
#ifndef VV_COLOR
#define VV_COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#endif

#ifndef VV_DEGREES_TO_RADIAN
#define VV_DEGREES_TO_RADIAN(x) (M_PI * (x) / 180.0)
#endif

/******************************************************************************/

@class VVImageStorage;

typedef BOOL(^VVAsyncDisplayIsCanclledBlock)(void);

typedef void(^VVAsyncDisplayWillDisplayBlock)(CALayer *layer);

typedef void(^VVAsyncDisplayBlock)(CALayer *layer, CGContextRef context, CGSize size, VVAsyncDisplayIsCanclledBlock isCancelledBlock);

typedef void(^VVAsyncDisplayDidDisplayBlock)(CALayer *layer, BOOL finished);

typedef void(^VVHTMLImageResizeBlock)(VVImageStorage *imageStorage, CGFloat delta);

typedef void(^VVAsyncCompleteBlock)(void);

/******************************************************************************/


#endif /* VVRichTextDefine_h */
