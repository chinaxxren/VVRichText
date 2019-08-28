
#import "GifController.h"

#import "VVWidgetCollect.h"
#import "VVAsynView.h"
#import "VVImage.h"
#import "VVTextParser.h"

@interface GifController ()

@property(nonatomic, strong) VVAsynView *asynView;
@property(nonatomic, strong) VVWidgetCollect *viewDto;

@end

@implementation GifController

- (void)dealloc {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];


    /*//1)
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"EmoticonQQ.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    bundlePath = [bundle pathForResource:@"001" ofType:@"gif"];
    VVImage *image = (VVImage *) [VVImage imageWithContentsOfFile:bundlePath];

    VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
    imageWidget.contents = image;
    imageWidget.frame = CGRectMake((200.0f - 32.0f) * 0.5f,(200.0f - 32.0f) * 0.5f, 32, 32);
    imageWidget.localImageType = VVLocalImageTypeDrawInVVAsyncImageView;
    imageWidget.contentMode = UIViewContentModeScaleAspectFill;

     self.layout = [[VVLayout alloc] init];
    [self.layout addWidget:imageWidget];
     */

    //2)
    /*
     VVImage *image = (VVImage *) [VVImage imageNamed:@"football.gif"];
    VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
    imageWidget.contents = image;
    imageWidget.frame = CGRectMake((200.0f - 96.0f) * 0.5f, (200.0f - 64.0f) * 0.5f, 96, 64);
    imageWidget.localImageType = VVLocalImageTypeDrawInVVAsyncImageView;
    imageWidget.contentMode = UIViewContentModeScaleAspectFill;

    self.layout = [[VVLayout alloc] init];
    [self.layout addWidget:imageWidget];
     */

    VVTextWidget *textWidget = [VVTextWidget new];
    textWidget.text = @"显示测试[001]显示测试[003]";
    textWidget.font = [UIFont systemFontOfSize:14.0f];
    textWidget.frame = CGRectMake(0.0f, 0.0f, 200.0f, CGFLOAT_MAX);

    // 解析表情
    [VVTextParser parseGifEmojiWithTextWidget:textWidget];

    self.viewDto = [[VVWidgetCollect alloc] init];
    [self.viewDto addWidget:textWidget];

    self.asynView = [[VVAsynView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 200.0f) * 0.5f, (self.view.bounds.size.height - 200) * 0.5f, 200.0f, 200.0f)];
    self.asynView.widgetCollect = self.viewDto;
    [self.view addSubview:self.asynView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(test)];

}

- (void)test {
}


@end
