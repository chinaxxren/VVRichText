
#import "FeedCell.h"

#import "VVImageStorage.h"
#import "MenuView.h"

@interface FeedCell () <VVAsyncViewDelegate>

@property(nonatomic, strong) VVAsynView *asyncView;
@property(nonatomic, strong) UIButton *menuButton;
@property(nonatomic, strong) MenuView *menu;
@property(nonatomic, strong) UIView *line;
@property(nonatomic, copy) NSString *preCopyText;

@end

@implementation FeedCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];

        [self.contentView addSubview:self.asyncView];
        [self.contentView addSubview:self.menuButton];
        [self.contentView addSubview:self.menu];
        [self.contentView addSubview:self.line];
    }
    return self;
}

#pragma mark - VVAsyncViewDelegate

//额外的绘制
- (void)vv_extraAsyncIncontext:(CGContextRef)context
                          size:(CGSize)size
                   isCancelled:(VVAsyncIsCanclledBlock)isCancelled {
    if (!isCancelled()) {
        CGContextMoveToPoint(context, 0.0f, size.height);
        CGContextAddLineToPoint(context, size.width, size.height);
        CGContextSetLineWidth(context, 0.2f);
        CGContextSetStrokeColorWithColor(context, VV_COLOR(220.0f, 220.0f, 220.0f, 1).CGColor);
        CGContextStrokePath(context);
        if ([self.feedLayout.statusModel.type isEqualToString:MESSAGE_TYPE_WEBSITE]) {
            CGContextAddRect(context, self.feedLayout.websitePosition);
            CGContextSetFillColorWithColor(context, VV_COLOR(240, 240, 240, 1).CGColor);
            CGContextFillPath(context);
        }
    }
}

//点击VVImageStorage
- (void)vv_asynView:(VVAsynView *)asynView didCilickedImageStorage:(VVImageStorage *)imageStorage touch:(UITouch *)touch {
    NSInteger tag = imageStorage.tag;
    //tag 0~8 是图片，9是头像
    switch (tag) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8: {
            if (self.clickedImageCallback) {
                self.clickedImageCallback(self, tag);
            }
            break;
        }
        case 9: {
            if (self.clickedAvatarCallback) {
                self.clickedAvatarCallback(self);
            }
            break;
        }
        default:
            break;
    }
}

//点击VVTextStorage
- (void)vv_asynView:(VVAsynView *)asynView didCilickedTextStorage:(VVTextStorage *)textStorage linkdata:(id)data {
    //回复评论
    if ([data isKindOfClass:[CommentModel class]]) {
        if (self.clickedReCommentCallback) {
            self.clickedReCommentCallback(self, data);
        }
    } else if ([data isKindOfClass:[NSString class]]) {
        //折叠Cell
        if ([data isEqualToString:@"close"]) {
            if (self.clickedCloseCellCallback) {
                self.clickedCloseCellCallback(self);
            }
        }
            //展开Cell
        else if ([data isEqualToString:@"open"]) {
            if (self.clickedOpenCellCallback) {
                self.clickedOpenCellCallback(self);
            }
        }
            //其他
        else {

        }
    }
}


//长按内容文字
- (void)vv_asynView:(VVAsynView *)asynView didLongpressedTextStorage:(VVTextStorage *)textStorage linkdata:(id)data {
    [self becomeFirstResponder];
    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyText)];
    [[UIMenuController sharedMenuController] setMenuItems:@[copyLink]];

    CGRect rect = CGRectMake(textStorage.center.x - 50.0f, textStorage.top, 100.0f, 50.0f);
    [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowDown;
    [[UIMenuController sharedMenuController] setTargetRect:rect inView:self];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    self.preCopyText = data;
}

//复制
- (void)copyText {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.preCopyText;

    [self resignFirstResponder];
    [self.asyncView vv_removeHighlightIfNeed];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyText)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Actions

//点击菜单按钮
- (void)didClickedMenuButton {
    [self.menu clickedMenu];
}

//点击评论
- (void)didClickedCommentButton {
    if (self.clickedCommentButtonCallback) {
        self.clickedCommentButtonCallback(self);
        [self.menu menuHide];
    }
}

//点赞
- (void)didClickedLikeButton:(LikeButton *)likeButton {
    __weak typeof(self) weakSelf = self;
    [likeButton likeButtonAnimationCompletion:^(BOOL isSelectd) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself.menu menuHide];
        if (sself.clickedLikeButtonCallback) {
            sself.clickedLikeButtonCallback(sself, !sself.feedLayout.statusModel.isLike);
        }
    }];
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];

    self.asyncView.frame = CGRectMake(0, 0, VV_SCREEN_WIDTH, self.feedLayout.height);

    self.menuButton.frame = self.feedLayout.menuPosition;
    self.menu.frame = CGRectMake(self.feedLayout.menuPosition.origin.x - 5.0f, self.feedLayout.menuPosition.origin.y - 9.0f + 14.5f, 0.0f, 34.0f);
    self.line.frame = self.feedLayout.lineRect;
}

- (void)setFeedLayout:(FeedLayout *)feedLayout {
    [self.menu menuHide];

    if (_feedLayout && [feedLayout isEqual:_feedLayout]) {
        return;
    }

    _feedLayout = feedLayout;
    self.asyncView.layout = self.feedLayout;
    self.menu.statusModel = self.feedLayout.statusModel;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    if (_displaysAsynchronously != displaysAsynchronously) {
        _displaysAsynchronously = displaysAsynchronously;
    }
    self.asyncView.asynDisplay = self.displaysAsynchronously;
}

#pragma mark - Getter

- (VVAsynView *)asyncView {
    if (_asyncView) {
        return _asyncView;
    }

    _asyncView = [[VVAsynView alloc] initWithFrame:CGRectZero];
    _asyncView.delegate = self;
    _asyncView.imageLevel = YES;
    return _asyncView;
}

- (UIButton *)menuButton {
    if (_menuButton) {
        return _menuButton;
    }

    _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_menuButton setImage:[UIImage imageNamed:@"[menu]"] forState:UIControlStateNormal];
    _menuButton.imageEdgeInsets = UIEdgeInsetsMake(14.5f, 12.0f, 14.5f, 12.0f);
    [_menuButton addTarget:self action:@selector(didClickedMenuButton) forControlEvents:UIControlEventTouchUpInside];
    return _menuButton;
}

- (MenuView *)menu {
    if (_menu) {
        return _menu;
    }

    _menu = [[MenuView alloc] initWithFrame:CGRectZero];
    _menu.backgroundColor = [UIColor whiteColor];
    _menu.opaque = YES;
    [_menu.commentButton addTarget:self action:@selector(didClickedCommentButton)
                  forControlEvents:UIControlEventTouchUpInside];
    [_menu.likeButton addTarget:self action:@selector(didClickedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    return _menu;
}

- (UIView *)line {
    if (_line) {
        return _line;
    }

    _line = [[UIView alloc] initWithFrame:CGRectZero];
    _line.backgroundColor = VV_COLOR(220.0f, 220.0f, 220.0f, 1.0f);
    return _line;
}

@end
