
#import "RichTextController.h"
#import "VVRichText.h"


@interface RichTextController () <VVAsyncViewDelegate>

@property(nonatomic, strong) VVAsynView *asyncView;
@property(nonatomic, copy) NSString *preCopyText;

@end

@implementation RichTextController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"VVTextStorage示例";
    self.view.backgroundColor = [UIColor whiteColor];

    //创建VVAsyncView对象
    self.asyncView = [[VVAsynView alloc] initWithFrame:CGRectMake(0.0f,
            64.0,
            VV_SCREEN_WIDTH,
            VV_SCREEN_HEIGHT - 64.0f)];

    //设置代理
    self.asyncView.delegate = self;
    [self.view addSubview:self.asyncView];


    //创建VVTextStorage对象
    VVTextStorage *ts = [[VVTextStorage alloc] init];
    ts.frame = CGRectMake(20, 30.0f, VV_SCREEN_WIDTH - 40.0f, CGFLOAT_MAX);
    ts.text = @"VVRichText支持图文混排,可以在文字中插入本地图片→网络图片→这UIView的子类→.给指定位置文字添加链接.快来试试吧。";
    ts.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];

    //在文字中插入本地图片
    [ts vv_replaceTextWithImage:[UIImage imageNamed:@"test"]
                    contentMode:UIViewContentModeScaleToFill
                      imageSize:CGSizeMake(50.0f, 50.0f)
                      alignment:VVTextAttachAlignmentTop
                          range:NSMakeRange(26, 0)];

    // 在文字中插入网络图片
    [ts vv_replaceTextWithImageURL:[NSURL URLWithString:@"http://ww2.sinaimg.cn/mw690/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg"]
                       contentMode:UIViewContentModeScaleAspectFill
                         imageSize:CGSizeMake(50, 50.0f)
                         alignment:VVTextAttachAlignmentTop
                             range:NSMakeRange(32, 0)];

    //在文字中插入UIView的子类
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [ts vv_replaceTextWithView:switchView
                   contentMode:UIViewContentModeScaleAspectFill
                          size:switchView.frame.size
                     alignment:VVTextAttachAlignmentTop
                         range:NSMakeRange(44, 0)];

    //给某位置的文字添加点击事件
    [ts vv_addLinkWithData:@"链接 ：）"
                     range:NSMakeRange(53, 4)
                 linkColor:[UIColor blueColor]
            highLightColor:VV_COLOR(0, 0, 0, 0.15)];

    //给整段文本添加点击事件
    [ts vv_addLinkForWholeTextStorageWithData:@"第一段"
                               highLightColor:VV_COLOR(0, 0, 0, 0.15f)];

    //给文本添加长按事件
    [ts vv_addLongPressActionWithData:ts.text
                       highLightColor:VV_COLOR(0, 0, 0, 0.25f)];


    //用属性字符串创建VVTextStorage
    NSMutableAttributedString *as1 = [[NSMutableAttributedString alloc] initWithString:@"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。"];
    [as1 setFont:[UIFont fontWithName:@"Heiti SC" size:13.0f] range:NSMakeRange(0, as1.length)];
    [as1 setTextBackgroundColor:[UIColor orangeColor] range:NSMakeRange(0, 9)];
    [as1 setTextColor:[UIColor whiteColor] range:NSMakeRange(0, 9)];
    [as1 setTextColor:[UIColor blackColor] range:NSMakeRange(9, as1.length - 9)];
    [as1 setUnderlineStyle:NSUnderlineStyleDouble underlineColor:[UIColor blueColor]
                     range:NSMakeRange(9, as1.length - 20)];

    [as1 setTextBackgroundColor:VV_COLOR(43, 187, 228, 0.9f) range:NSMakeRange(as1.length - 10, 10)];
    [as1 setTextColor:[UIColor whiteColor] range:NSMakeRange(as1.length - 10, 10)];

    VVTextStorage *ts1 = [VVTextStorage vv_textStorageWithText:as1
                                                         frame:CGRectMake(20.0f,
                                                                 ts.bottom + 20.0f,
                                                                 VV_SCREEN_WIDTH - 40.0f,
                                                                 CGFLOAT_MAX)];
    ts1.linespacing = 3.0f;


    VVTextStorage *ts2 = [[VVTextStorage alloc] init];
    ts2.text = @"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。The world puts off its mask of vastness to its lover.It becomes small as one song, as one kiss of the eternal.";
    ts2.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    ts2.textAlignment = NSTextAlignmentCenter;//设置居中
    ts2.needDebug = YES;//设置为调试模式
    ts2.frame = CGRectMake(20.0f,
            ts1.bottom + 20.0f,
            VV_SCREEN_WIDTH - 40.0f,
            200.0f);
    ts2.linespacing = 8.0f;
    ts2.vericalAlignment = VVTextVericalAlignmentCenter;//垂直方向居中对齐


    //创建VVLayout对象
    VVLayout *layout = [[VVLayout alloc] init];
    //将VVTextStorage对象添加到VVLayout对象中
    [layout addStorages:@[ts]];
    //将VVLayout对象赋值给VVAsyncView对象
    self.asyncView.layout = layout;
}

//给文字添加点击事件后，若触发事件，会在这个代理方法中收到回调
- (void)vv_asynView:(VVAsynView *)asynView didCilickedTextStorage:(VVTextStorage *)textStorage linkdata:(id)data {
    NSLog(@"点击:%@", data);
    if ([data isKindOfClass:[NSString class]]) {

    }
}

//给文字添加长按事件后，触发后，会在这个代理方法中收到回调
- (void)vv_asynView:(VVAsynView *)asynView didLongpressedTextStorage:(VVTextStorage *)textStorage linkdata:(id)data {
    [self becomeFirstResponder];
    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyText)];
    [[UIMenuController sharedMenuController] setMenuItems:@[copyLink]];

    CGRect rect = CGRectMake(textStorage.center.x - 50.0f, textStorage.top, 100.0f, 50.0f);
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
