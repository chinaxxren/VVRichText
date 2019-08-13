
#import "FeedWidgetStore.h"

#import "VVTextParser.h"

@implementation FeedWidgetStore

- (id)initWithStatusModel:(StatusModel *)statusModel index:(NSInteger)index dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self) {

        @autoreleasepool {

            self.statusModel = statusModel;

            // 头像模型 avatarImageWidget
            VVImageWidget *avatarWidget = [[VVImageWidget alloc] initWithIdentifier:AVATAR_IDENTIFIER];
            if (statusModel.avatar) {
                avatarWidget.contents = statusModel.avatar;
            } else {
                avatarWidget.contents = [UIImage imageNamed:@"defaultavatar.png"];
            }
            avatarWidget.cornerRadius = 20.0f;
            avatarWidget.cornerBackgroundColor = [UIColor whiteColor];
            avatarWidget.backgroundColor = [UIColor whiteColor];
            avatarWidget.frame = CGRectMake(10, 20, 40, 40);
            avatarWidget.tag = 9;
            avatarWidget.cornerBorderWidth = 1.0f;
            avatarWidget.cornerBorderColor = [UIColor grayColor];
            [self addWidget:avatarWidget];

            // 名字模型 nameTextWidget
            VVTextWidget *nameTextWidget = [[VVTextWidget alloc] init];
            nameTextWidget.text = statusModel.name;
            nameTextWidget.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
            nameTextWidget.frame = CGRectMake(60.0f, 20.0f, VV_SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
            [nameTextWidget vv_addLinkWithData:[NSString stringWithFormat:@"%@", statusModel.name]
                                          range:NSMakeRange(0, statusModel.name.length)
                                      linkColor:VV_COLOR(113, 129, 161, 1)
                                 highLightColor:VV_COLOR(0, 0, 0, 0.15)];
            [self addWidget:nameTextWidget];

            // 正文内容模型 contentTextWidget
            VVTextWidget *contentTextWidget = [[VVTextWidget alloc] init];
            if (statusModel.isExpend) {
                contentTextWidget.maxNumberOfLines = 0;
            } else {
                contentTextWidget.maxNumberOfLines = 5;//设置最大行数，超过则折叠
            }
            contentTextWidget.text = statusModel.content;
            contentTextWidget.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
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
            [self addWidget:contentTextWidget];

            CGFloat contentBottom = contentTextWidget.bottom;

            // 折叠文字
            VVTextWidget *expendWidget = [[VVTextWidget alloc] init];
            expendWidget.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
            expendWidget.textColor = VV_COLOR(40, 40, 40, 1);
            expendWidget.frame = CGRectMake(nameTextWidget.left, contentTextWidget.bottom + 5.0f, 200.0f, 30.0f);
            if (contentTextWidget.isTruncation && !statusModel.isExpend) {
                expendWidget.text = @"展开全文";
                [expendWidget vv_addLinkWithData:@"open"
                                            range:NSMakeRange(0, 4)
                                        linkColor:VV_COLOR(113, 129, 161, 1)
                                   highLightColor:VV_COLOR(0, 0, 0, 0.15f)];
                [self addWidget:expendWidget];
                contentBottom = expendWidget.bottom;
            } else if (statusModel.isExpend) {
                expendWidget.text = @"收起全文";
                [expendWidget vv_addLinkWithData:@"close"
                                            range:NSMakeRange(0, 4)
                                        linkColor:VV_COLOR(113, 129, 161, 1)
                                   highLightColor:VV_COLOR(0, 0, 0, 0.15f)];
                [self addWidget:expendWidget];
                contentBottom = expendWidget.bottom + 10.0f;
            }

            //发布的图片模型 imgsWidget
            CGFloat imageWidth = (VV_SCREEN_WIDTH - 110.0f) / 3.0f;
            NSInteger imageCount = [statusModel.imgs count];
            NSMutableArray *imageWidgetArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
            NSMutableArray *imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];

            //图片类型
            if ([statusModel.type isEqualToString:MESSAGE_TYPE_IMAGE]) {
                NSInteger row = 0;
                NSInteger column = 0;
                if (imageCount == 1) {
                    CGRect imageRect = CGRectMake(nameTextWidget.left,
                            contentBottom + 5.0f + (row * (imageWidth + 5.0f)),
                            imageWidth * 1.7f,
                            imageWidth * 1.7f);
                    NSString *imagePositionString = NSStringFromCGRect(imageRect);
                    [imagePositionArray addObject:imagePositionString];

                    VVImageWidget *imageWidget = [[VVImageWidget alloc] initWithIdentifier:IMAGE_IDENTIFIER];
                    imageWidget.tag = 0;
                    imageWidget.contentMode = UIViewContentModeScaleAspectFill;
                    imageWidget.clipsToBounds = YES;
                    imageWidget.frame = imageRect;
                    imageWidget.backgroundColor = VV_COLOR(240, 240, 240, 1);
                    imageWidget.contents = [NSURL URLWithString:statusModel.imgs[0]];
                    [imageWidgetArray addObject:imageWidget];
                } else {
                    for (NSInteger i = 0; i < imageCount; i++) {
                        CGRect imageRect = CGRectMake(nameTextWidget.left + (column * (imageWidth + 5.0f)),
                                contentBottom + 5.0f + (row * (imageWidth + 5.0f)),
                                imageWidth,
                                imageWidth);
                        NSString *imagePositionString = NSStringFromCGRect(imageRect);
                        [imagePositionArray addObject:imagePositionString];
                        VVImageWidget *imageWidget = [[VVImageWidget alloc] initWithIdentifier:IMAGE_IDENTIFIER];
                        imageWidget.clipsToBounds = YES;
                        imageWidget.contentMode = UIViewContentModeScaleAspectFill;
                        imageWidget.tag = i;
                        imageWidget.frame = imageRect;
                        imageWidget.backgroundColor = VV_COLOR(240, 240, 240, 1);
                        imageWidget.contents = [NSURL URLWithString:statusModel.imgs[i]];
                        [imageWidgetArray addObject:imageWidget];
                        column = column + 1;
                        if (column > 2) {
                            column = 0;
                            row = row + 1;
                        }
                    }
                }
            } else if ([statusModel.type isEqualToString:MESSAGE_TYPE_WEBSITE]) { //网页链接类型
                //这个CGRect用来绘制背景颜色
                self.websitePosition = CGRectMake(nameTextWidget.left, contentBottom + 5.0f, VV_SCREEN_WIDTH - 80.0f, 60.0f);

                //左边的图片
                VVImageWidget *imageWidget = [[VVImageWidget alloc] initWithIdentifier:WEBSITE_COVER_IDENTIFIER];
                NSString *URLString = statusModel.imgs[0];
                imageWidget.contents = [NSURL URLWithString:URLString];
                imageWidget.clipsToBounds = YES;
                imageWidget.contentMode = UIViewContentModeScaleAspectFill;
                imageWidget.frame = CGRectMake(nameTextWidget.left + 5.0f, contentBottom + 10.0f, 50.0f, 50.0f);
                [imageWidgetArray addObject:imageWidget];

                //右边的文字
                VVTextWidget *detailTextWidget = [[VVTextWidget alloc] init];
                detailTextWidget.text = statusModel.detail;
                detailTextWidget.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
                detailTextWidget.textColor = VV_COLOR(40, 40, 40, 1);
                detailTextWidget.frame = CGRectMake(imageWidget.right + 10.0f, contentBottom + 10.0f, VV_SCREEN_WIDTH - 150.0f, 60.0f);
                detailTextWidget.linespacing = 0.5f;
                [detailTextWidget vv_addLinkForWholeTextWidgetWithData:@"https://github.com/chinaxxren/VVRichText"
                                                         highLightColor:VV_COLOR(0, 0, 0, 0.15)];
                [self addWidget:detailTextWidget];
            } else if ([statusModel.type isEqualToString:MESSAGE_TYPE_VIDEO]) { //视频类型

            }
            [self addWidgets:imageWidgetArray];

            //获取最后一张图片的模型
            VVImageWidget *lastImageWidget = (VVImageWidget *) [imageWidgetArray lastObject];
            //生成时间的模型 dateTextWidget
            VVTextWidget *dateTextWidget = [[VVTextWidget alloc] init];
            dateTextWidget.text = [dateFormatter stringFromDate:statusModel.date];
            dateTextWidget.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
            dateTextWidget.textColor = [UIColor grayColor];

            //菜单按钮
            CGRect menuPosition = CGRectZero;
            if (![statusModel.type isEqualToString:MESSAGE_TYPE_VIDEO]) {
                menuPosition = CGRectMake(VV_SCREEN_WIDTH - 54.0f, 10.0f + contentTextWidget.bottom - 14.5f, 44.0f, 44.0f);
                dateTextWidget.frame = CGRectMake(nameTextWidget.left, contentTextWidget.bottom + 10.0f, VV_SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
                if (lastImageWidget) {
                    menuPosition = CGRectMake(VV_SCREEN_WIDTH - 54.0f, 10.0f + lastImageWidget.bottom - 14.5f, 44.0f, 44.0f);
                    dateTextWidget.frame = CGRectMake(nameTextWidget.left, lastImageWidget.bottom + 10.0f, VV_SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
                }
            }
            [self addWidget:dateTextWidget];

            //生成评论背景
            CGRect commentBgPosition = CGRectZero;
            CGRect rect = CGRectMake(60.0f, dateTextWidget.bottom + 5.0f, VV_SCREEN_WIDTH - 80, 20);

            CGFloat offsetY = 0.0f;

            //点赞
            VVImageWidget *likeImageWidget = [[VVImageWidget alloc] init];
            VVTextWidget *likeTextWidget = [[VVTextWidget alloc] init];
            if (statusModel.likeList.count != 0) {
                likeImageWidget.contents = [UIImage imageNamed:@"Like"];
                likeImageWidget.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY, 16.0f, 16.0f);
                [self addWidget:likeImageWidget];
                NSMutableString *mutableString = [[NSMutableString alloc] init];
                NSMutableArray *composeArray = [[NSMutableArray alloc] init];

                int rangeOffset = 0;
                for (NSInteger i = 0; i < statusModel.likeList.count; i++) {
                    NSString *liked = statusModel.likeList[i];
                    [mutableString appendString:liked];
                    NSRange range = NSMakeRange(rangeOffset, liked.length);
                    [composeArray addObject:[NSValue valueWithRange:range]];
                    rangeOffset += liked.length;
                    if (i != statusModel.likeList.count - 1) {
                        NSString *dotString = @",";
                        [mutableString appendString:dotString];
                        rangeOffset += 1;
                    }
                }

                likeTextWidget.text = mutableString;
                likeTextWidget.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                likeTextWidget.frame = CGRectMake(likeImageWidget.right + 5.0f, rect.origin.y + 7.0f, VV_SCREEN_WIDTH - 110.0f, CGFLOAT_MAX);

                for (NSValue *rangeValue in composeArray) {
                    NSRange range = [rangeValue rangeValue];
                    CommentModel *commentModel = [[CommentModel alloc] init];
                    commentModel.to = [likeTextWidget.text substringWithRange:range];
                    commentModel.index = index;
                    [likeTextWidget vv_addLinkWithData:commentModel
                                                  range:range
                                              linkColor:VV_COLOR(113, 129, 161, 1)
                                         highLightColor:VV_COLOR(0, 0, 0, 0.15)];
                }
                [self addWidget:likeTextWidget];
                offsetY += likeTextWidget.height + 5.0f;
            }

            if (statusModel.commentList.count != 0 && statusModel.commentList != nil) {
                if (self.statusModel.likeList.count != 0) {
                    self.lineRect = CGRectMake(nameTextWidget.left, likeTextWidget.bottom + 2.5f, VV_SCREEN_WIDTH - 80, 0.1f);
                }

                for (NSDictionary *commentDict in statusModel.commentList) {
                    NSString *to = commentDict[@"to"];
                    if (to.length != 0) {
                        NSString *commentString = [NSString stringWithFormat:@"%@回复%@:%@",
                                                                             commentDict[@"from"],
                                                                             commentDict[@"to"],
                                                                             commentDict[@"content"]];

                        VVTextWidget *commentTextWidget = [[VVTextWidget alloc] init];
                        commentTextWidget.text = commentString;
                        commentTextWidget.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                        commentTextWidget.textColor = VV_COLOR(40, 40, 40, 1);
                        commentTextWidget.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY, VV_SCREEN_WIDTH - 95.0f, CGFLOAT_MAX);

                        CommentModel *commentModel1 = [[CommentModel alloc] init];
                        commentModel1.to = commentDict[@"from"];
                        commentModel1.index = index;
                        [commentTextWidget vv_addLinkForWholeTextWidgetWithData:commentModel1
                                                                  highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [commentTextWidget vv_addLinkWithData:commentModel1
                                                         range:NSMakeRange(0, [(NSString *) commentDict[@"from"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        CommentModel *commentModel2 = [[CommentModel alloc] init];
                        commentModel2.to = [NSString stringWithFormat:@"%@", commentDict[@"to"]];
                        commentModel2.index = index;
                        [commentTextWidget vv_addLinkWithData:commentModel2
                                                         range:NSMakeRange([(NSString *) commentDict[@"from"] length] + 2,
                                                                 [(NSString *) commentDict[@"to"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [VVTextParser parseTopicWithVVTextWidget:commentTextWidget
                                                       linkColor:VV_COLOR(113, 129, 161, 1)
                                                  highlightColor:VV_COLOR(0, 0, 0, 0.15)];
                        [VVTextParser parseGeneralEmojiWithTextWidget:commentTextWidget];
                        [self addWidget:commentTextWidget];
                        offsetY += commentTextWidget.height;
                    } else {
                        NSString *commentString = [NSString stringWithFormat:@"%@:%@",
                                                                             commentDict[@"from"],
                                                                             commentDict[@"content"]];

                        VVTextWidget *commentTextWidget = [[VVTextWidget alloc] init];
                        commentTextWidget.text = commentString;
                        commentTextWidget.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                        commentTextWidget.textAlignment = NSTextAlignmentLeft;
                        commentTextWidget.linespacing = 2.0f;
                        commentTextWidget.textColor = VV_COLOR(40, 40, 40, 1);
                        commentTextWidget.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY, VV_SCREEN_WIDTH - 95.0f, CGFLOAT_MAX);

                        CommentModel *commentModel = [[CommentModel alloc] init];
                        commentModel.to = commentDict[@"from"];
                        commentModel.index = index;
                        [commentTextWidget vv_addLinkForWholeTextWidgetWithData:commentModel
                                                                  highLightColor:VV_COLOR(0, 0, 0, 0.15)];
                        [commentTextWidget vv_addLinkWithData:commentModel
                                                         range:NSMakeRange(0, [(NSString *) commentDict[@"from"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [VVTextParser parseTopicWithVVTextWidget:commentTextWidget
                                                       linkColor:VV_COLOR(113, 129, 161, 1)
                                                  highlightColor:VV_COLOR(0, 0, 0, 0.15)];
                        [VVTextParser parseGeneralEmojiWithTextWidget:commentTextWidget];
                        [self addWidget:commentTextWidget];
                        offsetY += commentTextWidget.height;
                    }
                }
                commentBgPosition = CGRectMake(60.0f, dateTextWidget.bottom + 5.0f, VV_SCREEN_WIDTH - 80, offsetY + 15.0f);
                VVImageWidget *commentBgWidget = [[VVImageWidget alloc] init];
                commentBgWidget.frame = commentBgPosition;
                commentBgWidget.contents = [UIImage imageNamed:@"comment"];
                [commentBgWidget vv_stretchableImageWithLeftCapWidth:40 topCapHeight:15];
                commentBgWidget.level = -1;
                [self addWidget:commentBgWidget];
            }

            self.avatarPosition = CGRectMake(10, 20, 40, 40);//头像的位置
            self.menuPosition = menuPosition;//右下角菜单按钮的位置
            self.commentBgPosition = commentBgPosition;//评论灰色背景位置
            self.imagePostions = imagePositionArray;//保存图片位置的数组

            //如果是使用在UITableViewCell上面，可以通过以下方法快速的得到Cell的高度
            self.height = [self suggestHeightWithBottomMargin:15.0f];
        }
    }
    return self;
}

@end
