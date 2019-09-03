
#import "RichTextController.h"
#import "VVRichText.h"


@interface RichTextController () <VVAsyncViewDelegate>

@property(nonatomic, strong) VVAsynView *asyncView;
@property(nonatomic, copy) NSString *preCopyText;

@end

@implementation RichTextController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"VVTextWidget示例";
    self.view.backgroundColor = [UIColor whiteColor];

    //创建VVAsyncView对象
    self.asyncView = [[VVAsynView alloc] initWithFrame:CGRectMake(0.0f, 64.0, VV_SCREEN_WIDTH, VV_SCREEN_HEIGHT - 64.0f)];
    self.asyncView.delegate = self;//设置代理
    [self.view addSubview:self.asyncView];


    //创建VVTextWidget对象
    VVTextWidget *tw0 = [[VVTextWidget alloc] init];
    tw0.frame = CGRectMake(20, 30.0f, VV_SCREEN_WIDTH - 40.0f, CGFLOAT_MAX);
    tw0.text = @"VVRichText支持图文混排,可以在文字中插入本地图片→网络图片→这UIView的子类→.给指定位置文字添加链接.快来试试吧。";
    tw0.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    // tw0.needDebugDraw = YES;

    //在文字中插入本地图片
    [tw0 vv_replaceTextWithImage:[UIImage imageNamed:@"test"]
                     contentMode:UIViewContentModeScaleToFill
                       imageSize:CGSizeMake(50.0f, 50.0f)
                       alignment:VVTextAttachAlignmentTop
                           range:NSMakeRange(26, 0)];

    // 在文字中插入网络图片
    [tw0 vv_replaceTextWithImageURL:[NSURL URLWithString:@"http://ww2.sinaimg.cn/mw690/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg"]
                        contentMode:UIViewContentModeScaleAspectFill
                          imageSize:CGSizeMake(50, 50.0f)
                          alignment:VVTextAttachAlignmentTop
                              range:NSMakeRange(32, 0)];

    //在文字中插入UIView的子类
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [tw0 vv_replaceTextWithView:switchView
                    contentMode:UIViewContentModeScaleAspectFill
                           size:switchView.frame.size
                      alignment:VVTextAttachAlignmentTop
                          range:NSMakeRange(44, 0)];

    //给某位置的文字添加点击事件
    [tw0 vv_addLinkWithData:@"链接 ：）"
                      range:NSMakeRange(53, 4)
                  linkColor:[UIColor blueColor]
             highLightColor:VV_COLOR(0, 0, 0, 0.15)];

    //给整段文本添加点击事件
    [tw0 vv_addLinkForWholeTextWidgetWithData:@"第一段"
                               highLightColor:VV_COLOR(0, 0, 0, 0.15f)];

    //给文本添加长按事件
    [tw0 vv_addLongPressActionWithData:tw0.text
                        highLightColor:VV_COLOR(0, 0, 0, 0.25f)];


    //用属性字符串创建VVTextWidget
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。"];
    [attributedText setFont:[UIFont fontWithName:@"Heiti SC" size:13.0f] range:NSMakeRange(0, attributedText.length)];
    [attributedText setTextBackgroundColor:[UIColor orangeColor] range:NSMakeRange(0, 9)];
    [attributedText setTextColor:[UIColor whiteColor] range:NSMakeRange(0, 9)];
    [attributedText setTextColor:[UIColor blackColor] range:NSMakeRange(9, attributedText.length - 9)];
    [attributedText setUnderlineStyle:NSUnderlineStyleDouble underlineColor:[UIColor blueColor]
                                range:NSMakeRange(9, attributedText.length - 20)];

    [attributedText setTextBackgroundColor:VV_COLOR(43, 187, 228, 0.9f) range:NSMakeRange(attributedText.length - 10, 10)];
    [attributedText setTextColor:[UIColor whiteColor] range:NSMakeRange(attributedText.length - 10, 10)];

    VVTextWidget *tw1 = [VVTextWidget vv_textWidgetWithText:attributedText
                                                      frame:CGRectMake(20.0f,
                                                              tw0.bottom + 20.0f,
                                                              VV_SCREEN_WIDTH - 40.0f,
                                                              CGFLOAT_MAX)];
    tw1.linespacing = 3.0f;


    VVTextWidget *tw2 = [[VVTextWidget alloc] init];
    tw2.text = @"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。The world puts off its mask of vastness to its lover.It becomes small as one song, as one kiss of the eternal.";
    tw2.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    tw2.textAlignment = NSTextAlignmentCenter;//设置居中
    tw2.needDebugDraw = YES;//设置为调试模式
    tw2.frame = CGRectMake(20.0f,
            tw1.bottom + 20.0f,
            VV_SCREEN_WIDTH - 40.0f,
            200.0f);
    tw2.linespacing = 8.0f;
    tw2.vericalAlignment = VVTextVericalAlignmentCenter;//垂直方向居中对齐


    VVWidgetCollect *viewDto = [VVWidgetCollect new];
    [viewDto addWidgets:@[tw0]];
    self.asyncView.widgetCollect = viewDto;
}

//给文字添加点击事件后，若触发事件，会在这个代理方法中收到回调
- (void)vv_asynView:(VVAsynView *)asynView didCilickedTextWidget:(VVTextWidget *)textWidget linkdata:(id)data {
    NSLog(@"点击:%@", data);
    if ([data isKindOfClass:[NSString class]]) {

    }
}

//给文字添加长按事件后，触发后，会在这个代理方法中收到回调
- (void)vv_asynView:(VVAsynView *)asynView didLongpressedTextWidget:(VVTextWidget *)textWidget linkdata:(id)data {
    [self becomeFirstResponder];
    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyText)];
    [[UIMenuController sharedMenuController] setMenuItems:@[copyLink]];

    CGRect rect = CGRectMake(textWidget.center.x - 50.0f, textWidget.top, 100.0f, 50.0f);
    [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowDown;
    [[UIMenuController sharedMenuController] setTargetRect:rect inView:self.view];
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

@end
