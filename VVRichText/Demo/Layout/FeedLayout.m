
#import "FeedLayout.h"

#import "VVTextParser.h"

@implementation FeedLayout

- (id)initWithStatusModel:(StatusModel *)statusModel index:(NSInteger)index dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self) {

        @autoreleasepool {

            self.statusModel = statusModel;

            //头像模型 avatarImageStorage
            VVImageStorage *avatarStorage = [[VVImageStorage alloc] initWithIdentifier:AVATAR_IDENTIFIER];
            if (statusModel.avatar) {
                avatarStorage.contents = statusModel.avatar;
            } else {
                avatarStorage.contents = [UIImage imageNamed:@"defaultavatar.png"];
            }
            avatarStorage.cornerRadius = 20.0f;
            avatarStorage.cornerBackgroundColor = [UIColor whiteColor];
            avatarStorage.backgroundColor = [UIColor whiteColor];
            avatarStorage.frame = CGRectMake(10, 20, 40, 40);
            avatarStorage.tag = 9;
            avatarStorage.cornerBorderWidth = 1.0f;
            avatarStorage.cornerBorderColor = [UIColor grayColor];

            //名字模型 nameTextStorage
            VVTextStorage *nameTextStorage = [[VVTextStorage alloc] init];
            nameTextStorage.text = statusModel.name;
            nameTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
            nameTextStorage.frame = CGRectMake(60.0f, 20.0f, VV_SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
            [nameTextStorage vv_addLinkWithData:[NSString stringWithFormat:@"%@", statusModel.name]
                                          range:NSMakeRange(0, statusModel.name.length)
                                      linkColor:VV_COLOR(113, 129, 161, 1)
                                 highLightColor:VV_COLOR(0, 0, 0, 0.15)];
            [nameTextStorage vv_Layout];

            //正文内容模型 contentTextStorage
            VVTextStorage *contentTextStorage = [[VVTextStorage alloc] init];
            contentTextStorage.maxNumberOfLines = 5;//设置最大行数，超过则折叠
            contentTextStorage.text = statusModel.content;
            contentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
            contentTextStorage.textColor = VV_COLOR(40, 40, 40, 1);
            contentTextStorage.frame = CGRectMake(nameTextStorage.left,
                    nameTextStorage.bottom + 10.0f,
                    VV_SCREEN_WIDTH - 80.0f,
                    CGFLOAT_MAX);
            [contentTextStorage vv_Layout];

            CGFloat contentBottom = contentTextStorage.bottom;
            //折叠的条件
            if (contentTextStorage.isTruncation) {
                contentTextStorage.frame = CGRectMake(nameTextStorage.left,
                        nameTextStorage.bottom + 10.0f,
                        VV_SCREEN_WIDTH - 80.0f,
                        CGFLOAT_MAX);

                VVTextStorage *openStorage = [[VVTextStorage alloc] init];
                openStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
                openStorage.textColor = VV_COLOR(40, 40, 40, 1);
                openStorage.frame = CGRectMake(nameTextStorage.left,
                        contentTextStorage.bottom + 5.0f,
                        200.0f,
                        30.0f);
                openStorage.text = @"展开全文";
                [openStorage vv_addLinkWithData:@"open"
                                          range:NSMakeRange(0, 4)
                                      linkColor:VV_COLOR(113, 129, 161, 1)
                                 highLightColor:VV_COLOR(0, 0, 0, 0.15f)];
                [self addStorage:openStorage];
                contentBottom = openStorage.bottom;
            }

            //解析表情、主题、网址
            [VVTextParser parseGeneralEmojiWithTextStorage:contentTextStorage];
            [VVTextParser parseTopicWithVVTextStorage:contentTextStorage
                                            linkColor:VV_COLOR(113, 129, 161, 1)
                                       highlightColor:VV_COLOR(0, 0, 0, 0.15)];
            [VVTextParser parseHttpURLWithTextStorage:contentTextStorage
                                            linkColor:VV_COLOR(113, 129, 161, 1)
                                       highlightColor:VV_COLOR(0, 0, 0, 0.15f)];
            //添加长按复制
            [contentTextStorage vv_addLongPressActionWithData:contentTextStorage.text
                                               highLightColor:VV_COLOR(0, 0, 0, 0.25f)];

            [contentTextStorage vv_Layout];

            //发布的图片模型 imgsStorage
            CGFloat imageWidth = (VV_SCREEN_WIDTH - 110.0f) / 3.0f;
            NSInteger imageCount = [statusModel.imgs count];
            NSMutableArray *imageStorageArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
            NSMutableArray *imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];

            //图片类型
            if ([statusModel.type isEqualToString:MESSAGE_TYPE_IMAGE]) {
                NSInteger row = 0;
                NSInteger column = 0;
                if (imageCount == 1) {
                    CGRect imageRect = CGRectMake(nameTextStorage.left,
                            contentBottom + 5.0f + (row * (imageWidth + 5.0f)),
                            imageWidth * 1.7f,
                            imageWidth * 1.7f);
                    NSString *imagePositionString = NSStringFromCGRect(imageRect);
                    [imagePositionArray addObject:imagePositionString];

                    VVImageStorage *imageStorage = [[VVImageStorage alloc] initWithIdentifier:IMAGE_IDENTIFIER];
                    imageStorage.tag = 0;
                    imageStorage.contentMode = UIViewContentModeScaleAspectFill;
                    imageStorage.clipsToBounds = YES;
                    imageStorage.frame = imageRect;
                    imageStorage.backgroundColor = VV_COLOR(240, 240, 240, 1);
                    imageStorage.contents = [NSURL URLWithString:statusModel.imgs[0]];
                    [imageStorageArray addObject:imageStorage];
                } else {
                    for (NSInteger i = 0; i < imageCount; i++) {
                        CGRect imageRect = CGRectMake(nameTextStorage.left + (column * (imageWidth + 5.0f)),
                                contentBottom + 5.0f + (row * (imageWidth + 5.0f)),
                                imageWidth,
                                imageWidth);
                        NSString *imagePositionString = NSStringFromCGRect(imageRect);
                        [imagePositionArray addObject:imagePositionString];
                        VVImageStorage *imageStorage = [[VVImageStorage alloc] initWithIdentifier:IMAGE_IDENTIFIER];
                        imageStorage.clipsToBounds = YES;
                        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
                        imageStorage.tag = i;
                        imageStorage.frame = imageRect;
                        imageStorage.backgroundColor = VV_COLOR(240, 240, 240, 1);
                        imageStorage.contents = [NSURL URLWithString:statusModel.imgs[i]];
                        [imageStorageArray addObject:imageStorage];
                        column = column + 1;
                        if (column > 2) {
                            column = 0;
                            row = row + 1;
                        }
                    }
                }
            } else if ([statusModel.type isEqualToString:MESSAGE_TYPE_WEBSITE]) { //网页链接类型
                //这个CGRect用来绘制背景颜色
                self.websitePosition = CGRectMake(nameTextStorage.left,
                        contentBottom + 5.0f,
                        VV_SCREEN_WIDTH - 80.0f,
                        60.0f);

                //左边的图片
                VVImageStorage *imageStorage = [[VVImageStorage alloc] initWithIdentifier:WEBSITE_COVER_IDENTIFIER];
                NSString *URLString = statusModel.imgs[0];
                imageStorage.contents = [NSURL URLWithString:URLString];
                imageStorage.clipsToBounds = YES;
                imageStorage.contentMode = UIViewContentModeScaleAspectFill;
                imageStorage.frame = CGRectMake(nameTextStorage.left + 5.0f,
                        contentBottom + 10.0f,
                        50.0f,
                        50.0f);
                [imageStorageArray addObject:imageStorage];

                //右边的文字
                VVTextStorage *detailTextStorage = [[VVTextStorage alloc] init];
                detailTextStorage.text = statusModel.detail;
                detailTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
                detailTextStorage.textColor = VV_COLOR(40, 40, 40, 1);
                detailTextStorage.frame = CGRectMake(imageStorage.right + 10.0f,
                        contentBottom + 10.0f,
                        VV_SCREEN_WIDTH - 150.0f,
                        60.0f);

                detailTextStorage.linespacing = 0.5f;
                [detailTextStorage vv_addLinkForWholeTextStorageWithData:@"https://github.com/chinaxxren/VVRichText"
                                                          highLightColor:VV_COLOR(0, 0, 0, 0.15)];
                [self addStorage:detailTextStorage];
            } else if ([statusModel.type isEqualToString:MESSAGE_TYPE_VIDEO]) { //视频类型

            }

            //获取最后一张图片的模型
            VVImageStorage *lastImageStorage = (VVImageStorage *) [imageStorageArray lastObject];
            //生成时间的模型 dateTextStorage
            VVTextStorage *dateTextStorage = [[VVTextStorage alloc] init];
            dateTextStorage.text = [dateFormatter stringFromDate:statusModel.date];
            dateTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
            dateTextStorage.textColor = [UIColor grayColor];

            //菜单按钮
            CGRect menuPosition = CGRectZero;
            if (![statusModel.type isEqualToString:MESSAGE_TYPE_VIDEO]) {
                menuPosition = CGRectMake(VV_SCREEN_WIDTH - 54.0f,
                        10.0f + contentTextStorage.bottom - 14.5f,
                        44.0f,
                        44.0f);

                dateTextStorage.frame = CGRectMake(nameTextStorage.left,
                        contentTextStorage.bottom + 10.0f,
                        VV_SCREEN_WIDTH - 80.0f,
                        CGFLOAT_MAX);
                if (lastImageStorage) {
                    menuPosition = CGRectMake(VV_SCREEN_WIDTH - 54.0f,
                            10.0f + lastImageStorage.bottom - 14.5f,
                            44.0f,
                            44.0f);

                    dateTextStorage.frame = CGRectMake(nameTextStorage.left,
                            lastImageStorage.bottom + 10.0f,
                            VV_SCREEN_WIDTH - 80.0f,
                            CGFLOAT_MAX);
                }
            }
            [dateTextStorage vv_Layout];

            //生成评论背景Storage
            VVImageStorage *commentBgStorage = [[VVImageStorage alloc] init];
            NSArray *commentTextStorages = @[];
            CGRect commentBgPosition = CGRectZero;
            CGRect rect = CGRectMake(60.0f,
                    dateTextStorage.bottom + 5.0f,
                    VV_SCREEN_WIDTH - 80,
                    20);

            CGFloat offsetY = 0.0f;

            //点赞
            VVImageStorage *likeImageSotrage = [[VVImageStorage alloc] init];
            VVTextStorage *likeTextStorage = [[VVTextStorage alloc] init];
            if (statusModel.likeList.count != 0) {
                likeImageSotrage.contents = [UIImage imageNamed:@"Like"];
                likeImageSotrage.frame = CGRectMake(rect.origin.x + 10.0f,
                        rect.origin.y + 10.0f + offsetY,
                        16.0f,
                        16.0f);

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

                likeTextStorage.text = mutableString;
                likeTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                likeTextStorage.frame = CGRectMake(likeImageSotrage.right + 5.0f,
                        rect.origin.y + 7.0f,
                        VV_SCREEN_WIDTH - 110.0f,
                        CGFLOAT_MAX);

                for (NSValue *rangeValue in composeArray) {
                    NSRange range = [rangeValue rangeValue];
                    CommentModel *commentModel = [[CommentModel alloc] init];
                    commentModel.to = [likeTextStorage.text substringWithRange:range];
                    commentModel.index = index;
                    [likeTextStorage vv_addLinkWithData:commentModel
                                                  range:range
                                              linkColor:VV_COLOR(113, 129, 161, 1)
                                         highLightColor:VV_COLOR(0, 0, 0, 0.15)];
                }
                [likeTextStorage vv_Layout];
                offsetY += likeTextStorage.height + 5.0f;
            }

            if (statusModel.commentList.count != 0 && statusModel.commentList != nil) {
                if (self.statusModel.likeList.count != 0) {
                    self.lineRect = CGRectMake(nameTextStorage.left,
                            likeTextStorage.bottom + 2.5f,
                            VV_SCREEN_WIDTH - 80,
                            0.1f);
                }

                NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:statusModel.commentList.count];
                for (NSDictionary *commentDict in statusModel.commentList) {
                    NSString *to = commentDict[@"to"];
                    if (to.length != 0) {
                        NSString *commentString = [NSString stringWithFormat:@"%@回复%@:%@",
                                                                             commentDict[@"from"],
                                                                             commentDict[@"to"],
                                                                             commentDict[@"content"]];

                        VVTextStorage *commentTextStorage = [[VVTextStorage alloc] init];
                        commentTextStorage.text = commentString;
                        commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                        commentTextStorage.textColor = VV_COLOR(40, 40, 40, 1);
                        commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f,
                                rect.origin.y + 10.0f + offsetY,
                                VV_SCREEN_WIDTH - 95.0f,
                                CGFLOAT_MAX);

                        CommentModel *commentModel1 = [[CommentModel alloc] init];
                        commentModel1.to = commentDict[@"from"];
                        commentModel1.index = index;
                        [commentTextStorage vv_addLinkForWholeTextStorageWithData:commentModel1
                                                                   highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [commentTextStorage vv_addLinkWithData:commentModel1
                                                         range:NSMakeRange(0, [(NSString *) commentDict[@"from"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        CommentModel *commentModel2 = [[CommentModel alloc] init];
                        commentModel2.to = [NSString stringWithFormat:@"%@", commentDict[@"to"]];
                        commentModel2.index = index;
                        [commentTextStorage vv_addLinkWithData:commentModel2
                                                         range:NSMakeRange([(NSString *) commentDict[@"from"] length] + 2,
                                                                 [(NSString *) commentDict[@"to"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [VVTextParser parseTopicWithVVTextStorage:commentTextStorage
                                                        linkColor:VV_COLOR(113, 129, 161, 1)
                                                   highlightColor:VV_COLOR(0, 0, 0, 0.15)];
                        [VVTextParser parseGeneralEmojiWithTextStorage:commentTextStorage];
                        [commentTextStorage vv_Layout];
                        [tmp addObject:commentTextStorage];
                        offsetY += commentTextStorage.height;
                    } else {
                        NSString *commentString = [NSString stringWithFormat:@"%@:%@",
                                                                             commentDict[@"from"],
                                                                             commentDict[@"content"]];

                        VVTextStorage *commentTextStorage = [[VVTextStorage alloc] init];
                        commentTextStorage.text = commentString;
                        commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                        commentTextStorage.textAlignment = NSTextAlignmentLeft;
                        commentTextStorage.linespacing = 2.0f;
                        commentTextStorage.textColor = VV_COLOR(40, 40, 40, 1);
                        commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f,
                                rect.origin.y + 10.0f + offsetY,
                                VV_SCREEN_WIDTH - 95.0f,
                                CGFLOAT_MAX);

                        CommentModel *commentModel = [[CommentModel alloc] init];
                        commentModel.to = commentDict[@"from"];
                        commentModel.index = index;
                        [commentTextStorage vv_addLinkForWholeTextStorageWithData:commentModel
                                                                   highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [commentTextStorage vv_addLinkWithData:commentModel
                                                         range:NSMakeRange(0, [(NSString *) commentDict[@"from"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [VVTextParser parseTopicWithVVTextStorage:commentTextStorage
                                                        linkColor:VV_COLOR(113, 129, 161, 1)
                                                   highlightColor:VV_COLOR(0, 0, 0, 0.15)];
                        [VVTextParser parseGeneralEmojiWithTextStorage:commentTextStorage];
                        [commentTextStorage vv_Layout];
                        [tmp addObject:commentTextStorage];
                        offsetY += commentTextStorage.height;
                    }
                }
                //如果有评论，设置评论背景Storage
                commentTextStorages = tmp;
                commentBgPosition = CGRectMake(60.0f,
                        dateTextStorage.bottom + 5.0f,
                        VV_SCREEN_WIDTH - 80,
                        offsetY + 15.0f);

                commentBgStorage.frame = commentBgPosition;
                commentBgStorage.contents = [UIImage imageNamed:@"comment"];
                [commentBgStorage vv_stretchableImageWithLeftCapWidth:40 topCapHeight:15];
            }

            [self addStorage:nameTextStorage];//将Storage添加到遵循VVLayoutProtocol协议的类
            [self addStorage:contentTextStorage];
            [self addStorage:dateTextStorage];
            [self addStorages:commentTextStorages];//通过一个数组来添加storage，使用这个方法
            [self addStorage:avatarStorage];
            [self addStorage:commentBgStorage];
            [self addStorage:likeImageSotrage];
            [self addStorages:imageStorageArray];//通过一个数组来添加storage，使用这个方法
            if (likeTextStorage) {
                [self addStorage:likeTextStorage];
            }
            self.avatarPosition = CGRectMake(10, 20, 40, 40);//头像的位置
            self.menuPosition = menuPosition;//右下角菜单按钮的位置
            self.commentBgPosition = commentBgPosition;//评论灰色背景位置
            self.imagePostions = imagePositionArray;//保存图片位置的数组

            //如果是使用在UITableViewCell上面，可以通过以下方法快速的得到Cell的高度
            self.cellHeight = [self suggestHeightWithBottomMargin:15.0f];
        }
    }
    return self;
}

- (id)initContentOpendLayoutWithStatusModel:(StatusModel *)statusModel index:(NSInteger)index dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self) {
        @autoreleasepool {

            self.statusModel = statusModel;

            //头像模型 avatarImageStorage
            VVImageStorage *avatarStorage = [[VVImageStorage alloc] initWithIdentifier:AVATAR_IDENTIFIER];
            avatarStorage.contents = statusModel.avatar;
            avatarStorage.cornerRadius = 20.0f;
            avatarStorage.cornerBackgroundColor = [UIColor whiteColor];
            avatarStorage.backgroundColor = [UIColor whiteColor];
            avatarStorage.frame = CGRectMake(10, 20, 40, 40);
            avatarStorage.tag = 9;
            avatarStorage.cornerBorderWidth = 1.0f;
            avatarStorage.cornerBorderColor = [UIColor grayColor];

            //名字模型 nameTextStorage
            VVTextStorage *nameTextStorage = [[VVTextStorage alloc] init];
            nameTextStorage.text = statusModel.name;
            nameTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
            nameTextStorage.frame = CGRectMake(60.0f, 20.0f, VV_SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
            [nameTextStorage vv_addLinkWithData:[NSString stringWithFormat:@"%@", statusModel.name]
                                          range:NSMakeRange(0, statusModel.name.length)
                                      linkColor:VV_COLOR(113, 129, 161, 1)
                                 highLightColor:VV_COLOR(0, 0, 0, 0.15)];
            [nameTextStorage vv_Layout];

            //正文内容模型 contentTextStorage
            VVTextStorage *contentTextStorage = [[VVTextStorage alloc] init];
            contentTextStorage.text = statusModel.content;
            contentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
            contentTextStorage.textColor = VV_COLOR(40, 40, 40, 1);
            contentTextStorage.frame = CGRectMake(nameTextStorage.left,
                    nameTextStorage.bottom + 10.0f,
                    VV_SCREEN_WIDTH - 80.0f,
                    CGFLOAT_MAX);
            [contentTextStorage vv_Layout];

            //折叠文字
            VVTextStorage *closeStorage = [[VVTextStorage alloc] init];
            closeStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
            closeStorage.textColor = VV_COLOR(40, 40, 40, 1);
            closeStorage.frame = CGRectMake(nameTextStorage.left,
                    contentTextStorage.bottom + 5.0f,
                    200.0f,
                    30.0f);
            closeStorage.text = @"收起全文";
            [closeStorage vv_addLinkWithData:@"close"
                                       range:NSMakeRange(0, 4)
                                   linkColor:VV_COLOR(113, 129, 161, 1)
                              highLightColor:VV_COLOR(0, 0, 0, 0.15f)];
            [self addStorage:closeStorage];
            CGFloat contentBottom = closeStorage.bottom + 10.0f;

            //解析表情、主题、网址
            [VVTextParser parseGeneralEmojiWithTextStorage:contentTextStorage];
            [VVTextParser parseTopicWithVVTextStorage:contentTextStorage
                                            linkColor:VV_COLOR(113, 129, 161, 1)
                                       highlightColor:VV_COLOR(0, 0, 0, 0.15)];
            [VVTextParser parseHttpURLWithTextStorage:contentTextStorage
                                            linkColor:VV_COLOR(113, 129, 161, 1)
                                       highlightColor:VV_COLOR(0, 0, 0, 0.15f)];


            //添加长按复制
            [contentTextStorage vv_addLongPressActionWithData:contentTextStorage.text
                                               highLightColor:VV_COLOR(0, 0, 0, 0.25f)];
            [contentTextStorage vv_Layout];

            //发布的图片模型 imgsStorage
            CGFloat imageWidth = (VV_SCREEN_WIDTH - 110.0f) / 3.0f;
            NSInteger imageCount = [statusModel.imgs count];
            NSMutableArray *imageStorageArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
            NSMutableArray *imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];

            //图片类型
            if ([statusModel.type isEqualToString:MESSAGE_TYPE_IMAGE]) {
                NSInteger row = 0;
                NSInteger column = 0;

                if (imageCount == 1) {
                    CGRect imageRect = CGRectMake(nameTextStorage.left,
                            contentBottom + 5.0f + (row * (imageWidth + 5.0f)),
                            imageWidth * 1.7f,
                            imageWidth * 1.7f);
                    NSString *imagePositionString = NSStringFromCGRect(imageRect);
                    [imagePositionArray addObject:imagePositionString];
                    VVImageStorage *imageStorage = [[VVImageStorage alloc] initWithIdentifier:IMAGE_IDENTIFIER];
                    imageStorage.tag = 0;
                    imageStorage.clipsToBounds = YES;
                    imageStorage.contentMode = UIViewContentModeScaleAspectFill;
                    imageStorage.frame = imageRect;
                    imageStorage.backgroundColor = VV_COLOR(240, 240, 240, 1);
                    NSString *URLString = statusModel.imgs[0];
                    imageStorage.contents = [NSURL URLWithString:URLString];
                    [imageStorageArray addObject:imageStorage];
                } else {
                    for (NSInteger i = 0; i < imageCount; i++) {
                        CGRect imageRect = CGRectMake(nameTextStorage.left + (column * (imageWidth + 5.0f)),
                                contentBottom + 5.0f + (row * (imageWidth + 5.0f)),
                                imageWidth,
                                imageWidth);

                        NSString *imagePositionString = NSStringFromCGRect(imageRect);
                        [imagePositionArray addObject:imagePositionString];
                        VVImageStorage *imageStorage = [[VVImageStorage alloc] initWithIdentifier:IMAGE_IDENTIFIER];
                        imageStorage.clipsToBounds = YES;
                        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
                        imageStorage.tag = i;
                        imageStorage.frame = imageRect;
                        imageStorage.backgroundColor = VV_COLOR(240, 240, 240, 1);
                        NSString *URLString = statusModel.imgs[i];
                        imageStorage.contents = [NSURL URLWithString:URLString];
                        [imageStorageArray addObject:imageStorage];
                        column = column + 1;
                        if (column > 2) {
                            column = 0;
                            row = row + 1;
                        }
                    }
                }
            }

                //网页链接类型
            else if ([statusModel.type isEqualToString:MESSAGE_TYPE_WEBSITE]) {
                //这个CGRect用来绘制背景颜色
                self.websitePosition = CGRectMake(nameTextStorage.left,
                        contentBottom + 5.0f,
                        VV_SCREEN_WIDTH - 80.0f,
                        60.0f);

                //左边的图片
                VVImageStorage *imageStorage = [[VVImageStorage alloc] initWithIdentifier:WEBSITE_COVER_IDENTIFIER];
                NSString *URLString = statusModel.imgs[0];
                imageStorage.contents = [NSURL URLWithString:URLString];
                imageStorage.clipsToBounds = YES;
                imageStorage.contentMode = UIViewContentModeScaleAspectFill;
                imageStorage.frame = CGRectMake(nameTextStorage.left + 5.0f,
                        contentBottom + 10.0f,
                        50.0f,
                        50.0f);
                [imageStorageArray addObject:imageStorage];

                //右边的文字
                VVTextStorage *detailTextStorage = [[VVTextStorage alloc] init];
                detailTextStorage.text = statusModel.detail;
                detailTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
                detailTextStorage.textColor = VV_COLOR(40, 40, 40, 1);
                detailTextStorage.frame = CGRectMake(imageStorage.right + 10.0f,
                        contentBottom + 10.0f,
                        VV_SCREEN_WIDTH - 150.0f,
                        60.0f);

                detailTextStorage.linespacing = 0.5f;
                [detailTextStorage vv_addLinkForWholeTextStorageWithData:@"https://github.com/chinaxxren/VVRichText"
                                                          highLightColor:VV_COLOR(0, 0, 0, 0.15)];
                [self addStorage:detailTextStorage];
            }

                //视频类型
            else if ([statusModel.type isEqualToString:MESSAGE_TYPE_VIDEO]) {
                //TODO：

            }

            //获取最后一张图片的模型
            VVImageStorage *lastImageStorage = (VVImageStorage *) [imageStorageArray lastObject];
            //生成时间的模型 dateTextStorage
            VVTextStorage *dateTextStorage = [[VVTextStorage alloc] init];
            dateTextStorage.text = [dateFormatter stringFromDate:statusModel.date];
            dateTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
            dateTextStorage.textColor = [UIColor grayColor];

            //菜单按钮
            CGRect menuPosition = CGRectZero;
            if (![statusModel.type isEqualToString:@"video"]) {
                menuPosition = CGRectMake(VV_SCREEN_WIDTH - 54.0f,
                        10.0f + contentTextStorage.bottom - 14.5f,
                        44.0f,
                        44.0f);

                dateTextStorage.frame = CGRectMake(nameTextStorage.left,
                        contentTextStorage.bottom + 10.0f,
                        VV_SCREEN_WIDTH - 80.0f,
                        CGFLOAT_MAX);
                if (lastImageStorage) {
                    menuPosition = CGRectMake(VV_SCREEN_WIDTH - 54.0f,
                            10.0f + lastImageStorage.bottom - 14.5f,
                            44.0f,
                            44.0f);

                    dateTextStorage.frame = CGRectMake(nameTextStorage.left,
                            lastImageStorage.bottom + 10.0f,
                            VV_SCREEN_WIDTH - 80.0f,
                            CGFLOAT_MAX);
                }
            }
            [dateTextStorage vv_Layout];

            //生成评论背景Storage
            VVImageStorage *commentBgStorage = [[VVImageStorage alloc] init];
            NSArray *commentTextStorages = @[];
            CGRect commentBgPosition = CGRectZero;
            CGRect rect = CGRectMake(60.0f,
                    dateTextStorage.bottom + 5.0f,
                    VV_SCREEN_WIDTH - 80,
                    20);

            CGFloat offsetY = 0.0f;
            //点赞
            VVImageStorage *likeImageSotrage = [[VVImageStorage alloc] init];
            VVTextStorage *likeTextStorage = [[VVTextStorage alloc] init];
            if (statusModel.likeList.count != 0) {
                likeImageSotrage.contents = [UIImage imageNamed:@"Like"];
                likeImageSotrage.frame = CGRectMake(rect.origin.x + 10.0f,
                        rect.origin.y + 10.0f + offsetY,
                        16.0f,
                        16.0f);

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

                likeTextStorage.text = mutableString;
                likeTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                likeTextStorage.frame = CGRectMake(likeImageSotrage.right + 5.0f,
                        rect.origin.y + 7.0f,
                        VV_SCREEN_WIDTH - 110.0f,
                        CGFLOAT_MAX);

                for (NSValue *rangeValue in composeArray) {
                    NSRange range = [rangeValue rangeValue];
                    CommentModel *commentModel = [[CommentModel alloc] init];
                    commentModel.to = [likeTextStorage.text substringWithRange:range];
                    commentModel.index = index;
                    [likeTextStorage vv_addLinkWithData:commentModel
                                                  range:range
                                              linkColor:VV_COLOR(113, 129, 161, 1)
                                         highLightColor:VV_COLOR(0, 0, 0, 0.15)];
                }
                [likeTextStorage vv_Layout];
                offsetY += likeTextStorage.height + 5.0f;
            }
            if (statusModel.commentList.count != 0 &&
                    statusModel.commentList != nil) {
                if (statusModel.likeList.count != 0) {
                    self.lineRect = CGRectMake(nameTextStorage.left,
                            likeTextStorage.bottom + 2.5f,
                            VV_SCREEN_WIDTH - 80,
                            0.1f);
                }

                NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:statusModel.commentList.count];
                for (NSDictionary *commentDict in statusModel.commentList) {
                    NSString *to = commentDict[@"to"];
                    if (to.length != 0) {
                        NSString *commentString = [NSString stringWithFormat:@"%@回复%@:%@",
                                                                             commentDict[@"from"],
                                                                             commentDict[@"to"],
                                                                             commentDict[@"content"]];

                        VVTextStorage *commentTextStorage = [[VVTextStorage alloc] init];
                        commentTextStorage.text = commentString;
                        commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                        commentTextStorage.textColor = VV_COLOR(40, 40, 40, 1);
                        commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f,
                                rect.origin.y + 10.0f + offsetY,
                                VV_SCREEN_WIDTH - 95.0f,
                                CGFLOAT_MAX);

                        CommentModel *commentModel1 = [[CommentModel alloc] init];
                        commentModel1.to = commentDict[@"from"];
                        commentModel1.index = index;
                        [commentTextStorage vv_addLinkForWholeTextStorageWithData:commentModel1
                                                                   highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [commentTextStorage vv_addLinkWithData:commentModel1
                                                         range:NSMakeRange(0, [(NSString *) commentDict[@"from"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        CommentModel *commentModel2 = [[CommentModel alloc] init];
                        commentModel2.to = [NSString stringWithFormat:@"%@", commentDict[@"to"]];
                        commentModel2.index = index;
                        [commentTextStorage vv_addLinkWithData:commentModel2
                                                         range:NSMakeRange([(NSString *) commentDict[@"from"] length] + 2,
                                                                 [(NSString *) commentDict[@"to"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [VVTextParser parseTopicWithVVTextStorage:commentTextStorage
                                                        linkColor:VV_COLOR(113, 129, 161, 1)
                                                   highlightColor:VV_COLOR(0, 0, 0, 0.15)];
                        [VVTextParser parseGeneralEmojiWithTextStorage:commentTextStorage];
                        [commentTextStorage vv_Layout];
                        [tmp addObject:commentTextStorage];
                        offsetY += commentTextStorage.height;
                    } else {
                        NSString *commentString = [NSString stringWithFormat:@"%@:%@",
                                                                             commentDict[@"from"],
                                                                             commentDict[@"content"]];

                        VVTextStorage *commentTextStorage = [[VVTextStorage alloc] init];
                        commentTextStorage.text = commentString;
                        commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                        commentTextStorage.textAlignment = NSTextAlignmentLeft;
                        commentTextStorage.linespacing = 2.0f;
                        commentTextStorage.textColor = VV_COLOR(40, 40, 40, 1);

                        commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f,
                                rect.origin.y + 10.0f + offsetY,
                                VV_SCREEN_WIDTH - 95.0f,
                                CGFLOAT_MAX);

                        CommentModel *commentModel = [[CommentModel alloc] init];
                        commentModel.to = commentDict[@"from"];
                        commentModel.index = index;
                        [commentTextStorage vv_addLinkForWholeTextStorageWithData:commentModel
                                                                   highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [commentTextStorage vv_addLinkWithData:commentModel
                                                         range:NSMakeRange(0, [(NSString *) commentDict[@"from"] length])
                                                     linkColor:VV_COLOR(113, 129, 161, 1)
                                                highLightColor:VV_COLOR(0, 0, 0, 0.15)];

                        [VVTextParser parseTopicWithVVTextStorage:commentTextStorage
                                                        linkColor:VV_COLOR(113, 129, 161, 1)
                                                   highlightColor:VV_COLOR(0, 0, 0, 0.15)];
                        [VVTextParser parseGeneralEmojiWithTextStorage:commentTextStorage];
                        [commentTextStorage vv_Layout];
                        [tmp addObject:commentTextStorage];
                        offsetY += commentTextStorage.height;
                    }
                }
                //如果有评论，设置评论背景Storage
                commentTextStorages = tmp;
                commentBgPosition = CGRectMake(60.0f,
                        dateTextStorage.bottom + 5.0f,
                        VV_SCREEN_WIDTH - 80,
                        offsetY + 15.0f);

                commentBgStorage.frame = commentBgPosition;
                commentBgStorage.contents = [UIImage imageNamed:@"comment"];
                [commentBgStorage vv_stretchableImageWithLeftCapWidth:40
                                                         topCapHeight:15];
            }

            [self addStorage:nameTextStorage];//将Storage添加到遵循VVLayoutProtocol协议的类
            [self addStorage:contentTextStorage];
            [self addStorage:dateTextStorage];
            [self addStorages:commentTextStorages];//通过一个数组来添加storage，使用这个方法
            [self addStorage:avatarStorage];
            [self addStorage:commentBgStorage];
            [self addStorage:likeImageSotrage];
            [self addStorages:imageStorageArray];//通过一个数组来添加storage，使用这个方法
            if (likeTextStorage) {
                [self addStorage:likeTextStorage];
            }

            self.avatarPosition = CGRectMake(10, 20, 40, 40);//头像的位置
            self.menuPosition = menuPosition;//右下角菜单按钮的位置
            self.commentBgPosition = commentBgPosition;//评论灰色背景位置
            self.imagePostions = imagePositionArray;//保存图片位置的数组

            //如果是使用在UITableViewCell上面，可以通过以下方法快速的得到Cell的高度
            self.cellHeight = [self suggestHeightWithBottomMargin:15.0f];
        }
    }

    return self;

}

@end
