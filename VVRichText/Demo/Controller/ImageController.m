
#import "ImageController.h"
#import "ImageDemoTableViewCell.h"

@interface ImageController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ImageController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    self.title = @"VVImageStorage使用示例";

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    ImageDemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ImageDemoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    VVLayout *layout = self.dataSource[indexPath.row];
    cell.layout = layout;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0f;
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (_dataSource) {
        return _dataSource;
    }
    _dataSource = [[NSMutableArray alloc] init];

    {
        VVTextStorage *textStorage = [[VVTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textStorage.text = @"加载本地图片,默认图片会直接绘制在VVAsyncDisplayView上，减少View的层级。";
        textStorage.vericalAlignment = VVTextVericalAlignmentCenter;


        VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
        imageStorage.contents = [UIImage imageNamed:@"test"];
        imageStorage.backgroundColor = [UIColor grayColor];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);


        VVLayout *layout = [[VVLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }

    {
        VVTextStorage *textStorage = [[VVTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textStorage.text = @"加载本地图片，并设置圆角半径";
        textStorage.vericalAlignment = VVTextVericalAlignmentCenter;

        VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
        imageStorage.contents = [UIImage imageNamed:@"test"];
        imageStorage.backgroundColor = [UIColor grayColor];
        imageStorage.cornerRadius = 50.0f;
        imageStorage.cornerBackgroundColor = [UIColor whiteColor];
        imageStorage.cornerBorderColor = [UIColor redColor];
        imageStorage.cornerBorderWidth = 5.0f;
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);


        VVLayout *layout = [[VVLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }

    {
        VVTextStorage *textStorage = [[VVTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textStorage.text = @"加载本地图片，并进行模糊处理";
        textStorage.vericalAlignment = VVTextVericalAlignmentCenter;


        VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
        imageStorage.contents = [UIImage imageNamed:@"test"];
        imageStorage.backgroundColor = [UIColor grayColor];
        imageStorage.isBlur = YES;
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);


        VVLayout *layout = [[VVLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }

    {
        VVTextStorage *textStorage = [[VVTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textStorage.text = @"加载网络图片,并进行模糊处理，处理后的图片将直接缓存，下次加载时就无需再次处理而是直接读取缓存了。";
        textStorage.vericalAlignment = VVTextVericalAlignmentCenter;

        VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        imageStorage.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
        imageStorage.clipsToBounds = YES;
        imageStorage.isBlur = YES;

        VVLayout *layout = [[VVLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }

    /* {
         VVTextStorage *textStorage = [[VVTextStorage alloc] init];
         textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
         textStorage.text = @"加载网络图片";
         textStorage.vericalAlignment = VVTextVericalAlignmentCenter;

         VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
         imageStorage.contentMode = UIViewContentModeScaleAspectFill;
         imageStorage.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
         imageStorage.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
         imageStorage.clipsToBounds = YES;


         VVLayout *layout = [[VVLayout alloc] init];
         [layout addStorage:imageStorage];
         [layout addStorage:textStorage];
         [_dataSource addObject:layout];
     }

     {
         VVTextStorage *textStorage = [[VVTextStorage alloc] init];
         textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
         textStorage.text = @"加载网络图片,并设置圆角半径，处理后的图片将直接缓存，下次加载时就无需再次处理而是直接读取缓存了。";
         textStorage.vericalAlignment = VVTextVericalAlignmentCenter;


         VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
         imageStorage.contentMode = UIViewContentModeScaleAspectFill;
         imageStorage.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
         imageStorage.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
         imageStorage.clipsToBounds = YES;
         imageStorage.cornerRadius = 50.0f;
         imageStorage.cornerBorderColor = [UIColor orangeColor];
         imageStorage.cornerBorderWidth = 5.0f;

         VVLayout *layout = [[VVLayout alloc] init];
         [layout addStorage:imageStorage];
         [layout addStorage:textStorage];
         [_dataSource addObject:layout];
     }
 */
    {
        VVTextStorage *textStorage = [[VVTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textStorage.text = @"加载网络GIF图片";
        textStorage.vericalAlignment = VVTextVericalAlignmentCenter;

        VVImageStorage *imageStorage = [[VVImageStorage alloc] init];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        imageStorage.contents = [NSURL URLWithString:@"http://wx2.sinaimg.cn/bmiddle/784fda03gy1fcw8zl4zqrg209h04x7wi.gif"];
        imageStorage.clipsToBounds = YES;
        // gif thumbnail
//        imageStorage.contents = [NSURL URLWithString:@"http://ww3.sinaimg.cn/thumbnail/006qdyzsly1fctmnzwqcwg307505pasc.gif"];
        // real gif format
//        imageStorage.contents = [NSURL URLWithString:@"http://ww3.sinaimg.cn/bmiddle/006qdyzsly1fctmnzwqcwg307505pasc.gif"];

        VVLayout *layout = [[VVLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }

    return _dataSource;
}


@end
