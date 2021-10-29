
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


/******************************************************************************/

@class VVImageWidget;

typedef BOOL(^VVAsyncIsCanclledBlock)(void);

typedef void(^VVAsynWillDisplayBlock)(CALayer *layer);

typedef void(^VVAsynDoDisplayBlock)(CALayer *layer, CGContextRef context, CGSize size, VVAsyncIsCanclledBlock isCancelledBlock);

typedef void(^VVAsynDidDisplayBlock)(CALayer *layer, BOOL finished);

typedef void(^VVImageResizeBlock)(VVImageWidget *imageWidget, CGFloat delta);

typedef void(^VVAsynCompleteBlock)(void);

/******************************************************************************/


#endif /* VVRichTextDefine_h */
