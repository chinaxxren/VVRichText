
#import "ShowGifController.h"

#import "VVWidgetCollect.h"
#import "VVAsynView.h"
#import "VVImage.h"
#import "VVTextParser.h"

@interface ShowGifController ()

@property(nonatomic, strong) VVAsynView *asynView;
@property(nonatomic, strong) VVWidgetCollect *widgetCollect;

@end

@implementation ShowGifController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

//    [self demo1];

//    [self demo2];

    [self demo3];

    self.asynView = [[VVAsynView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 200.0f) * 0.5f, (self.view.bounds.size.height - 200) * 0.5f, 200.0f, 200.0f)];
    self.asynView.widgetCollect = self.widgetCollect;
    [self.view addSubview:self.asynView];
}

- (void)demo3 {
    VVTextWidget *textWidget = [VVTextWidget new];
    textWidget.text = @"显示测试[001]显示测试[003]";
    textWidget.font = [UIFont systemFontOfSize:14.0f];
    textWidget.frame = CGRectMake(0.0f, 0.0f, 200.0f, CGFLOAT_MAX);
    [VVTextParser parseGifEmojiWithTextWidget:textWidget];

    self.widgetCollect = [[VVWidgetCollect alloc] init];
    [self.widgetCollect addWidget:textWidget];
}

- (void)demo2 {
    VVImage *image = (VVImage *) [VVImage imageNamed:@"football.gif"];
    VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
    imageWidget.contents = image;
    imageWidget.frame = CGRectMake((200.0f - 96.0f) * 0.5f, (200.0f - 64.0f) * 0.5f, 96, 64);
    imageWidget.localImageType = VVLocalImageDrawInVVAsyncView;
    imageWidget.contentMode = UIViewContentModeScaleAspectFill;

    self.widgetCollect = [[VVWidgetCollect alloc] init];
    [self.widgetCollect addWidget:imageWidget];
}

- (void)demo1 {
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"EmoticonQQ.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    bundlePath = [bundle pathForResource:@"001" ofType:@"gif"];
    VVImage *image = (VVImage *) [VVImage imageWithContentsOfFile:bundlePath];

    VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
    imageWidget.contents = image;
    imageWidget.frame = CGRectMake((200.0f - 32.0f) * 0.5f, (200.0f - 32.0f) * 0.5f, 32, 32);
    imageWidget.localImageType = VVLocalImageDrawInVVAsyncView;
    imageWidget.contentMode = UIViewContentModeScaleAspectFill;

    self.widgetCollect = [[VVWidgetCollect alloc] init];
    [self.widgetCollect addWidget:imageWidget];
}

@end
