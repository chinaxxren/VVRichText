
#ifndef VVRichTextDefine_h
#define VVRichTextDefine_h

//屏幕宽
#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif


//屏幕高
#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif


//屏幕大小
#ifndef SCREEN_BOUNDS
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#endif


//通过RGB返回UIColor
#ifndef RGB
#define RGB(R, G, B, A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#endif

//获取iOS版本号
#ifndef IOS_VERSION
#define IOS_VERSION [[UIDevice currentDevice] systemVersion] floatValue]
#endif


//获取App版本号
#ifndef APP_VERSION
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#endif


//获取标准NSUserDefaults单例对象
#ifndef STANDARD_USER_DEFAULTS
#define STANDARD_USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#endif


//获取沙盒Document路径
#ifndef SAND_BOX_DOCUMENT_PATH
#define SAND_BOX_DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#endif


//获取沙盒Temp路径
#ifndef SAND_BOX_TEMP_PATH
#define SAND_BOX_TEMP_PATH NSTemporaryDirectory()
#endif


//获取沙盒Cache路径
#ifndef SAND_BOX_CACHE_PATH
#define SAND_BOX_CACHE_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
#endif


/******************************************************************************/

@class VVImageStorage;

typedef BOOL(^VVAsyncDisplayIsCanclledBlock)(void);

typedef void(^VVAsyncDisplayWillDisplayBlock)(CALayer *layer);

typedef void(^VVAsyncDisplayBlock)(CALayer *layer, CGContextRef context, CGSize size, VVAsyncDisplayIsCanclledBlock isCancelledBlock);

typedef void(^VVAsyncDisplayDidDisplayBlock)(CALayer *layer, BOOL finished);

typedef void(^VVHTMLImageResizeBlock)(VVImageStorage *imageStorage, CGFloat delta);

typedef void(^VVAsyncCompleteBlock)(void);

typedef void(^VVWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL);

typedef void(^VVWebImageDownloaderCompletionBlock)(UIImage *image, NSData *imageData, NSError *error);

/******************************************************************************/


#endif /* VVRichTextDefine_h */
