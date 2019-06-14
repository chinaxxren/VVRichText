
#import "FeedController.h"

#import "FeedCell.h"
#import "CommentView.h"
#import "FeedVM.h"

@interface FeedController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) FeedVM *feedVM;
@property(nonatomic, strong) CommentView *commentView;
@property(nonatomic, strong) CommentModel *postComment;
@property(nonatomic, assign) BOOL displaysAsynchronously;//是否异步绘制

@end

@implementation FeedController

#pragma mark - ViewControllerLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];


    self.feedVM = [FeedVM new];
    [self setupUI];


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(test)];
    [self loadData];
}

- (void)test {
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppearNotifications:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHidenNotifications:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedVM.datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:Feed_Cell forIndexPath:indexPath];
    [self confirgueCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedLayout *feedLayout = self.feedVM.datas[indexPath.row];
    CGFloat height = feedLayout.height;
    return height;
}

- (void)confirgueCell:(FeedCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.displaysAsynchronously = self.displaysAsynchronously;
    cell.indexPath = indexPath;
    FeedLayout *feedLayout = self.feedVM.datas[indexPath.row];
    cell.feedLayout = feedLayout;
    NSLog(@"cell index %zd", indexPath.row);
    [self callbackWithCell:cell];
}

- (void)callbackWithCell:(FeedCell *)cell {

    __weak typeof(self) weakSelf = self;
    cell.clickedLikeButtonCallback = ^(FeedCell *cell, BOOL isLike) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself tableViewCell:cell didClickedLikeButtonWithIsLike:isLike];
    };

    cell.clickedCommentButtonCallback = ^(FeedCell *cell) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself commentWithCell:cell];
    };

    cell.clickedReCommentCallback = ^(FeedCell *cell, CommentModel *model) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself reCommentWithCell:cell commentModel:model];
    };

    cell.clickedOpenCellCallback = ^(FeedCell *cell) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself openTableViewCell:cell];
    };

    cell.clickedCloseCellCallback = ^(FeedCell *cell) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself closeTableViewCell:cell];
    };

    cell.clickedAvatarCallback = ^(FeedCell *cell) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself showAvatarWithCell:cell];
    };

    cell.clickedImageCallback = ^(FeedCell *cell, NSInteger imageIndex) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself tableViewCell:cell showImageBrowserWithImageIndex:imageIndex];
    };
}

#pragma mark - Actions

//开始评论
- (void)commentWithCell:(FeedCell *)cell {
    self.postComment.from = @"china的粉丝";
    self.postComment.to = @"";
    self.postComment.index = cell.indexPath.row;
    self.commentView.placeHolder = @"评论";
    if (![self.commentView.textView isFirstResponder]) {
        [self.commentView.textView becomeFirstResponder];
    }
}

//开始回复评论
- (void)reCommentWithCell:(FeedCell *)cell commentModel:(CommentModel *)commentModel {
    self.postComment.from = @"beijing";
    self.postComment.to = commentModel.to;
    self.postComment.index = commentModel.index;
    self.commentView.placeHolder = [NSString stringWithFormat:@"回复%@:", commentModel.to];
    if (![self.commentView.textView isFirstResponder]) {
        [self.commentView.textView becomeFirstResponder];
    }
}

//点击查看大图
- (void)tableViewCell:(FeedCell *)cell showImageBrowserWithImageIndex:(NSInteger)imageIndex {
    NSString *imgURL = cell.feedLayout.statusModel.imgs[imageIndex];
    NSLog(@"imgURL->%@", imgURL);
}

//查看头像
- (void)showAvatarWithCell:(FeedCell *)cell {
    NSURL *avatarURL = cell.feedLayout.statusModel.avatar;
    NSLog(@"avatarURL->%@", avatarURL);
}

//点赞
- (void)tableViewCell:(FeedCell *)cell didClickedLikeButtonWithIsLike:(BOOL)isLike {
    NSInteger row = cell.indexPath.row;
    FeedLayout *feedLayout = self.feedVM.datas[row];
    NSMutableArray *newLikeList = [[NSMutableArray alloc] initWithArray:feedLayout.statusModel.likeList];
    if (isLike) {
        [newLikeList addObject:@"chinaxxren的粉丝"];
    } else {
        [newLikeList removeObject:@"chinaxxren的粉丝"];
    }

    StatusModel *statusModel = feedLayout.statusModel;
    statusModel.likeList = newLikeList;
    statusModel.isLike = isLike;
    feedLayout = [self.feedVM layoutWithStatusModel:statusModel index:row];

    self.feedVM.datas[row] = feedLayout;
    [self reloadCell:row];
}

//展开Cell
- (void)openTableViewCell:(FeedCell *)cell {
    NSInteger row = cell.indexPath.row;
    [self.feedVM expendData:row];
    [self reloadCell:row];
}

//折叠Cell
- (void)closeTableViewCell:(FeedCell *)cell {
    NSInteger row = cell.indexPath.row;
    [self.feedVM expendData:row];
    [self reloadCell:row];
}

//发表评论
- (void)postCommentWithCommentModel:(CommentModel *)commentModel {

    FeedLayout *feedLayout = self.feedVM.datas[commentModel.index];
    NSMutableArray *newCommentLists = [[NSMutableArray alloc] initWithArray:feedLayout.statusModel.commentList];
    NSDictionary *newComment = @{@"from": commentModel.from, @"to": commentModel.to, @"content": commentModel.content};
    [newCommentLists addObject:newComment];
    StatusModel *statusModel = feedLayout.statusModel;
    statusModel.commentList = newCommentLists;
    FeedLayout *newLayout = [self.feedVM layoutWithStatusModel:statusModel index:commentModel.index];

    self.feedVM.datas[commentModel.index] = newLayout;
    [self reloadCell:commentModel.index];
}

- (void)reloadCell:(NSInteger)row {
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

#pragma mark - Keyboard

- (void)keyboardDidAppearNotifications:(NSNotification *)notifications {
    NSDictionary *userInfo = [notifications userInfo];
    CGSize keyboardSize = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    self.commentView.frame = CGRectMake(0.0f, VV_SCREEN_HEIGHT - 44.0f - keyboardHeight, VV_SCREEN_WIDTH, 44.0f);
}

- (void)keyboardDidHidenNotifications:(NSNotification *)notifications {
    self.commentView.frame = CGRectMake(0, VV_SCREEN_HEIGHT, VV_SCREEN_WIDTH, 44.0f);
}

#pragma mark - Data

//模拟下载数据
- (void)loadData {
    [self.feedVM loadData];
    [self.tableView reloadData];
}

- (void)segmentControlIndexChanged:(UISegmentedControl *)segmentedControl {
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    switch (idx) {
        case 0:
            self.displaysAsynchronously = YES;
            break;
        case 1:
            self.displaysAsynchronously = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Getter

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.displaysAsynchronously = YES;

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"异步绘制开", @"异步绘制关"]];
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(segmentControlIndexChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.commentView];
}

- (CommentView *)commentView {
    if (_commentView) {
        return _commentView;
    }

    __weak typeof(self) wself = self;
    _commentView = [[CommentView alloc]
            initWithFrame:CGRectMake(0, VV_SCREEN_HEIGHT, VV_SCREEN_WIDTH, 54.0f)
                sendBlock:^(NSString *content) {
                    __strong  typeof(wself) swself = wself;
                    swself.postComment.content = content;
                    [swself postCommentWithCommentModel:swself.postComment];
                }];
    return _commentView;
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerClass:[FeedCell class] forCellReuseIdentifier:Feed_Cell];
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;

    return _tableView;
}

- (CommentModel *)postComment {
    if (_postComment) {
        return _postComment;
    }

    _postComment = [[CommentModel alloc] init];
    return _postComment;
}

@end
