

#import "AsynController.h"

#import "TextViewCell.h"

static const NSString *cellIdentifier = @"cellIdentifier";

@interface AsynController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation AsynController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"VVImageWidget使用示例";
    [self.view addSubview:self.tableView];

    [self dataSource];
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
    VVWidgetCollect *widgetCollect = self.dataSource[indexPath.row];
    cell.widgetCollect = widgetCollect;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 34.0f;
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
    for (int i = 0; i < 500; i++) {

        VVTextWidget *textWidget = [[VVTextWidget alloc] init];
        textWidget.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 34.0f);
        textWidget.maxNumberOfLines = 2;
        textWidget.textColor = [UIColor redColor];
        textWidget.font = [UIFont systemFontOfSize:8];
        textWidget.vericalAlignment = VVTextVericalAlignmentCenter;

        NSString *text;
        if (i < 2) {
            text = @"Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺";
            textWidget.textBackgroundColor = [UIColor greenColor];
        } else {
            text = [NSString stringWithFormat:@"%d Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫 Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫", i];
            textWidget.textBackgroundColor = [UIColor grayColor];
        }

        textWidget.text = text;

        VVWidgetCollect *widgetCollect = [VVWidgetCollect new];
        [widgetCollect addWidget:textWidget];
        [_dataSource addObject:widgetCollect];
    }

    return _dataSource;
}


@end
