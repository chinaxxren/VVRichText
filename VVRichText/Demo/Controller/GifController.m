
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

//    self.gifImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) *0.5f, 50, 100, 100)];
//    [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:@"http://ww3.sinaimg.cn/bmiddle/006qdyzsly1fctmnzwqcwg307505pasc.gif"]];
//    [self.view addSubview:self.gifImageView];

    VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
//    imageStorage.contents = [NSURL URLWithString:@"http://ww3.sinaimg.cn/bmiddle/006qdyzsly1fctmnzwqcwg307505pasc.gif"];
//    imageStorage.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
//    imageStorage.frame = CGRectMake(0.0, 0.0, 100, 100);

    imageStorage.contents = [VVImage imageNamed:@"1.gif"];
    imageStorage.frame = CGRectMake(0.0, 0.0, 28, 28);
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.displayView.layout = nil;
    self.displayView.layout = self.layout;
}


@end
