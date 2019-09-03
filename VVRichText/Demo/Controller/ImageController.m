
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
    self.title = @"VVImageWidget使用示例";
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
    VVWidgetCollect *widgetCollect = self.dataSource[indexPath.row];
    cell.widgetCollect = widgetCollect;
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
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载本地图片,默认图片会直接绘制在VVAsyncView上，减少View的层级。";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;


        VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
        imageWidget.contents = [UIImage imageNamed:@"test"];
        imageWidget.backgroundColor = [UIColor grayColor];
        imageWidget.contentMode = UIViewContentModeScaleAspectFill;
        imageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);


        VVWidgetCollect *widgetCollect = [[VVWidgetCollect alloc] init];
        [widgetCollect addWidget:imageWidget];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }

    {
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载本地图片，并设置圆角半径";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;

        VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
        imageWidget.contents = [UIImage imageNamed:@"test"];
        imageWidget.backgroundColor = [UIColor grayColor];
        imageWidget.cornerRadius = 50.0f;
        imageWidget.cornerBackgroundColor = [UIColor whiteColor];
        imageWidget.cornerBorderColor = [UIColor redColor];
        imageWidget.cornerBorderWidth = 5.0f;
        imageWidget.contentMode = UIViewContentModeScaleAspectFill;
        imageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);


        VVWidgetCollect *widgetCollect = [[VVWidgetCollect alloc] init];
        [widgetCollect addWidget:imageWidget];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }

    {
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载本地图片，并进行模糊处理";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;


        VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
        imageWidget.contents = [UIImage imageNamed:@"test"];
        imageWidget.backgroundColor = [UIColor grayColor];
        imageWidget.isBlur = YES;
        imageWidget.contentMode = UIViewContentModeScaleAspectFill;
        imageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);


        VVWidgetCollect *widgetCollect = [[VVWidgetCollect alloc] init];
        [widgetCollect addWidget:imageWidget];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }

    {
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载网络图片,并进行模糊处理，处理后的图片将直接缓存，下次加载时就无需再次处理而是直接读取缓存了。";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;

        VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
        imageWidget.contentMode = UIViewContentModeScaleAspectFill;
        imageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        imageWidget.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
        imageWidget.clipsToBounds = YES;
        imageWidget.isBlur = YES;

        VVWidgetCollect *widgetCollect = [[VVWidgetCollect alloc] init];
        [widgetCollect addWidget:imageWidget];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }

    {
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载网络图片";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;

        VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
        imageWidget.contentMode = UIViewContentModeScaleAspectFill;
        imageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        imageWidget.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
        imageWidget.clipsToBounds = YES;


        VVWidgetCollect *widgetManager = [[VVWidgetCollect alloc] init];
        [widgetManager addWidget:imageWidget];
        [widgetManager addWidget:textWidget];
        [_dataSource addObject:widgetManager];
    }

    {
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载网络图片,并设置圆角半径，处理后的图片将直接缓存，下次加载时就无需再次处理而是直接读取缓存了。";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;


        VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
        imageWidget.contentMode = UIViewContentModeScaleAspectFill;
        imageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        imageWidget.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
        imageWidget.clipsToBounds = YES;
        imageWidget.cornerRadius = 50.0f;
        imageWidget.cornerBorderColor = [UIColor orangeColor];
        imageWidget.cornerBorderWidth = 5.0f;

        VVWidgetCollect *widgetCollect = [[VVWidgetCollect alloc] init];
        [widgetCollect addWidget:imageWidget];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }
    
    {
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载网络GIF图片";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;
        
        VVImageWidget *vvImageWidget = [[VVImageWidget alloc] init];
        vvImageWidget.contentMode = UIViewContentModeScaleAspectFill;
        vvImageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        vvImageWidget.contents = [NSURL URLWithString:@"http://wx2.sinaimg.cn/bmiddle/784fda03gy1fcw8zl4zqrg209h04x7wi.gif"];
        vvImageWidget.clipsToBounds = YES;
        // gif thumbnail
        //        imageWidget.contents = [NSURL URLWithString:@"http://ww3.sinaimg.cn/thumbnail/006qdyzsly1fctmnzwqcwg307505pasc.gif"];
        // real gif format
        //        imageWidget.contents = [NSURL URLWithString:@"http://ww3.sinaimg.cn/bmiddle/006qdyzsly1fctmnzwqcwg307505pasc.gif"];
        
        VVWidgetCollect *widgetCollect = [VVWidgetCollect new];
        [widgetCollect addWidget:vvImageWidget];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }
    
    {
        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        textWidget.text = @"加载Webp图片";
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;

        VVImageWidget *vvImageWidget = [[VVImageWidget alloc] init];
        vvImageWidget.contentMode = UIViewContentModeScaleAspectFill;
        vvImageWidget.frame = CGRectMake(self.view.bounds.size.width / 2 + 15.0f, 15.0f, self.view.bounds.size.width / 2 - 30.0f, 100.0f);
        vvImageWidget.contents = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1387554-6f2bf47eabb4bcaf.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp"];
        vvImageWidget.clipsToBounds = YES;

        VVWidgetCollect *widgetCollect = [VVWidgetCollect new];
        [widgetCollect addWidget:vvImageWidget];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }
    
    return _dataSource;
}


@end
