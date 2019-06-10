
#import "GifController.h"

#import "VVLayout.h"
#import "VVAsyncDisplayView.h"
#import "VVImage.h"

@interface GifController ()

@property(nonatomic, strong) VVAsyncDisplayView *displayView;
@property(nonatomic, strong) VVLayout *layout;

@end

@implementation GifController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"EmoticonQQ.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    bundlePath = [bundle pathForResource:@"001" ofType:@"gif"];
    VVImage *image = (VVImage *) [VVImage imageWithContentsOfFile:bundlePath];
    VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
    imageStorage.contents = image;
    imageStorage.frame = CGRectMake(0.0, 0.0, 32, 32);
    imageStorage.localImageType = VVLocalImageTypeDrawInVVAsyncImageView;
    imageStorage.contentMode = UIViewContentModeScaleAspectFill;

    self.layout = [[VVLayout alloc] init];
    [self.layout addStorage:imageStorage];

    self.displayView = [[VVAsyncDisplayView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) * 0.5f, 200, 100, 100)];
    self.displayView.layout = self.layout;
    [self.view addSubview:self.displayView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(test)];

}

- (void)test {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Test"
                                                                             message:@"当 present 出 UIAlertController时, 界面上显示的图片全部不显示了"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

    }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:NULL];
}


@end
