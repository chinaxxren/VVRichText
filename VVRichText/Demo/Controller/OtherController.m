

#import "OtherController.h"
#import "TextViewCell.h"

static NSString *cellIdentifier = @"cellIdentifier";

@interface OtherController () <UITableViewDelegate, UITableViewDataSource>


@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation OtherController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"VVImageStorage使用示例";
    [self.view addSubview:self.tableView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(test)];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self dataSource];
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
//        });
//    });
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
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    VVLayout *layout = self.dataSource[indexPath.row];
    cell.layout = layout;
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

        VVTextStorage *textStorage = [[VVTextStorage alloc] init];
        textStorage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 34.0f);
        textStorage.maxNumberOfLines = 2;
        textStorage.textColor = [UIColor redColor];
        textStorage.font = [UIFont systemFontOfSize:8];
        textStorage.vericalAlignment = VVTextVericalAlignmentCenter;

        NSString *text;
        if (i < 2) {
            text = @"Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺";
            textStorage.textBackgroundColor = [UIColor greenColor];
        } else {
            text = [NSString stringWithFormat:@"%d Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫 Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫", i];
            textStorage.textBackgroundColor = [UIColor grayColor];
        }

        textStorage.text = text;

        VVLayout *layout = [[VVLayout alloc] init];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }

    return _dataSource;
}


@end
