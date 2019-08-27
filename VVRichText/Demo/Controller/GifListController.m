
#import "GifListController.h"

#import "TextViewCell.h"
#import "VVImage.h"

static NSString *cellIdentifier = @"cellIdentifier";
static CGFloat gifSize = 30;

@interface GifListController () <UITableViewDelegate, UITableViewDataSource>


@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation GifListController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"本地加载多个Gif使用示例";
    [self.view addSubview:self.tableView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(test)];

    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.text = @"数据加载中....";
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self dataSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"reloadData");
            [label removeFromSuperview];
            [self.tableView reloadData];
        });
    });
}

- (void)test {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    VVWidgetStore *layout = self.dataSource[indexPath.row];
    cell.layout = layout;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return gifSize;
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView registerClass:[TextViewCell class] forCellReuseIdentifier:cellIdentifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (_dataSource) {
        return _dataSource;
    }

    _dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < 300; i++) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        NSInteger count = (NSInteger) (width / gifSize);
        VVWidgetStore *layout = [[VVWidgetStore alloc] init];
        for (int j = 0; j < count - 1; j++) {
            NSInteger index = arc4random() % 141;
            NSString *name = [self gifWithIndex:index];
            
            NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"EmoticonQQ.bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            bundlePath = [bundle pathForResource:name ofType:@"gif"];
            VVImage *image = (VVImage *) [VVImage imageWithContentsOfFile:bundlePath];
            VVTextWidget *textWidget = [[VVTextWidget alloc] init];
            textWidget.frame = CGRectMake(0.0f, 0.0f, gifSize, gifSize);
            textWidget.text = [NSString stringWithFormat:@"%d", i];
            textWidget.textColor = [UIColor redColor];
            textWidget.vericalAlignment = VVTextVericalAlignmentCenter;
            [layout addWidget:textWidget];

            VVImageWidget *imageWidget = [[VVImageWidget alloc] init];
            imageWidget.frame = CGRectMake((j + 1) * gifSize, 0, gifSize, gifSize);
            imageWidget.contents = image;
            imageWidget.localImageType = VVLocalImageTypeDrawInVVImageView;
            imageWidget.contentMode = UIViewContentModeScaleAspectFill;
            [layout addWidget:imageWidget];
        }

        [_dataSource addObject:layout];
    }

    return _dataSource;
}

- (NSString *)gifWithRadom {
    NSInteger index = arc4random() % 141;
    NSString *name = [self gifWithIndex:index];
    return name;
}

- (NSString *)gifWithIndex:(NSInteger)index {
    NSMutableString *name = [NSMutableString new];
    if (index < 10) {
        [name appendString:@"00"];
    } else if (index < 100) {
        [name appendString:@"0"];
    }
    [name appendFormat:@"%zd", index];
    
    if([name isEqualToString:@"000"]) {
        return @"001";
    }
    
    return name;
}

@end

