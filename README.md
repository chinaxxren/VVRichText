
# VVRichText 

## 关于 

1. VVRichText 支持富文本显示,支持异步文本渲染。
1. 可以在文本中插入本地图片，网络图片或UIView对象。
1. 支持WebP、GIF等格式。
1. 支持添加单击和长按事件到文本、图片。
1. 绘制文本框架，绘制空心字，设置文本垂直对齐属性等。
1. 解析文本中的表达式，如http（s）链接、@user、＃theme＃、电话号码。
1. 快速设置图像角半径属性和模糊处理等。
1. 支持布局控制多个图文元素
1. 支持SDWebImage缓存库

##### 文字对象例子 TextWidget
* Feed正文内容模型  
```obj-c
VVTextWidget *contentTextWidget = [VVTextWidget new];
contentTextWidget.maxNumberOfLines = 0;
contentTextWidget.text = statusModel.content;
contentTextWidget.font = [UIFont systemFontOfSize:15.0f];
contentTextWidget.textColor = VV_COLOR(40, 40, 40, 1);
contentTextWidget.frame = CGRectMake(nameTextWidget.left, nameTextWidget.bottom + 10.0f, VV_SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
// 添加长按复制
[contentTextWidget vv_addLongPressActionWithData:contentTextWidget.text
                                  highLightColor:VV_COLOR(0, 0, 0, 0.25f)];
// 解析表情、主题、网址
[VVTextParser parseGeneralEmojiWithTextWidget:contentTextWidget];
[VVTextParser parseTopicWithVVTextWidget:contentTextWidget
                               linkColor:VV_COLOR(113, 129, 161, 1)
                          highlightColor:VV_COLOR(0, 0, 0, 0.15)];
[VVTextParser parseHttpURLWithTextWidget:contentTextWidget
                               linkColor:VV_COLOR(113, 129, 161, 1)
                          highlightColor:VV_COLOR(0, 0, 0, 0.15f)];
```

##### 图片对象例子 ImageWidget 
* Feed头像模型 
```obj-c
VVImageWidget *avatarWidget = [[VVImageWidget alloc] initWithIdentifier:AVATAR_IDENTIFIER];
if (statusModel.avatar) {
    avatarWidget.contents = statusModel.avatar;
} else {
    avatarWidget.contents = [UIImage imageNamed:@"defaultavatar.png"];
}
avatarWidget.cornerRadius = 20.0f;
avatarWidget.cornerBackgroundColor = [UIColor whiteColor];
avatarWidget.backgroundColor = [UIColor whiteColor];
avatarWidget.frame = CGRectMake(10.0f, 20.0f, 40.0f, 40.0f);
avatarWidget.tag = 9;
avatarWidget.cornerBorderWidth = 1.0f;
avatarWidget.cornerBorderColor = [UIColor grayColor];
```
* 将图片和文字的Widget对象添加到VVWidgetCollect中

```obj-c
[self addWidget:nameTextWidget];
[self addWidget:contentTextWidget];
```

* Cell高度计算

```obj-c
self.height = [self suggestHeightWithBottomMargin:15.0f];
```

* 单独更新一个Cell异步线程渲染会闪烁,切换为主线程渲染，比如点击展开Feed正文
```obj-c
//展开Cell
- (void)openTableViewCell:(FeedCell *)cell {
    NSInteger row = cell.indexPath.row;
    [self.feedVM expendData:row];
    [self reloadCell:row];
}

// 异步线程渲染会闪烁,切换为主线程渲染
- (void)reloadCell:(NSInteger)row {
    self.asynDisplay = NO;

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];

    self.asynDisplay = YES;
}
```

![](https://user-gold-cdn.xitu.io/2019/9/3/16cf525faeb378ed?w=650&h=734&f=png&s=282428)

## 集成

* 通过`pod 'VVRichText'`集成到项目中 
