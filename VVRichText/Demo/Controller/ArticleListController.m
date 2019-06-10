
#import "ArticleListController.h"
#import "ArticleListTableViewCell.h"

@interface ArticleListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,assign) BOOL isNeedRefresh;

@end

@implementation ArticleListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ariticle list";
    self.isNeedRefresh = YES;
    self.dataSource = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"articlelist" ofType:@"plist"];
    NSArray* list = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    for (NSDictionary* dict in list) {
        @autoreleasepool {
            ArticleListModel* model = [[ArticleListModel alloc] init];
            model.idString = dict[@"id"];
            model.images = dict[@"images"];
            model.title = dict[@"title"];
            [self.dataSource addObject:model];
        }
    }
    [self.tableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"cellID";
    ArticleListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ArticleListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    ArticleListModel* model = self.dataSource[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



@end
