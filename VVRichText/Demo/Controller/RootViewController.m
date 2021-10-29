
#import "RootViewController.h"

#import "RichTextController.h"
#import "FeedController.h"
#import "ImageController.h"
#import "ShowGifController.h"
#import "AsynController.h"
#import "ShowGifListController.h"

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;

    self.title = @"例子";

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"VVTextWidget使用示例";
            break;
        case 1:
            cell.textLabel.text = @"VVImageWidget使用示例";
            break;
        case 2:
            cell.textLabel.text = @"Feed List 示例";
            break;
        case 3:
            cell.textLabel.text = @"使用一个Gif示例";
            break;
        case 4:
            cell.textLabel.text = @"本地加载多个Gif使用示例";
            break;
        case 5:
            cell.textLabel.text = @"异步性能示例";
            break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case 0: {
            RichTextController *vc = [[RichTextController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: {
            ImageController *vc = [[ImageController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2: {
            FeedController *vc = [[FeedController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3: {
            ShowGifController *vc = [[ShowGifController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 4: {
            ShowGifListController *vc = [[ShowGifListController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 5: {
            AsynController *vc = [AsynController new];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }

        default:
            break;
    }
}

@end
