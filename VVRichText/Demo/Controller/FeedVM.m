//
// Created by Jiangmingz on 2019-06-13.
// Copyright (c) 2019 Jiangmingz. All rights reserved.
//

#import "FeedVM.h"

#import "StatusDto.h"
#import "VVWidgetCollect.h"
#import "FeedWidgetCollect.h"

@interface FeedVM ()

@property(nonatomic, strong) NSArray *feedDatas;

@end

@implementation FeedVM

- (NSMutableArray *)datas {
    if (_datas) {
        return _datas;
    }
    _datas = [[NSMutableArray alloc] init];
    return _datas;
}

- (void)loadData {
    [self.datas removeAllObjects];

    //让数据更多
    for (NSInteger i = 0; i < 10; i++) {
        for (NSInteger i = 0; i < self.feedDatas.count; i++) {
            VVWidgetCollect *viewDto = [self viewDtoWithStatusModel:[[StatusDto alloc] initWithDict:self.feedDatas[i]] index:i];
            [self.datas addObject:viewDto];
        }
    }
}

- (FeedWidgetCollect *)viewDtoWithStatusModel:(StatusDto *)statusModel index:(NSInteger)index {
    FeedWidgetCollect *vos = [[FeedWidgetCollect alloc] initWithStatusModel:statusModel index:index dateFormatter:self.dateFormatter];
    return vos;
}

- (void)expendData:(NSInteger)index {
    FeedWidgetCollect *vos = self.datas[index];
    StatusDto *model = vos.statusModel;
    model.isExpend = !model.isExpend;
    FeedWidgetCollect *newVOS = [[FeedWidgetCollect alloc] initWithStatusModel:model
                                                              index:index
                                                      dateFormatter:self.dateFormatter];
    self.datas[index] = newVOS;
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM月dd日 hh:mm"];
    });
    return dateFormatter;
}

- (NSArray *)feedDatas {
    if (_feedDatas) {
        return _feedDatas;
    }

    _feedDatas =
            @[
                    @{@"type": @"image",
                            @"name": @"型格志style",
                            @"avatar": @"",
                            @"content": @"春天卫衣的正确打开方式https://github.com/chinaxxren/VVRichText",
                            @"date": @"1459668442",

                            @"imgs": @[@"http://ww2.sinaimg.cn/bmiddle/006gWxKPgw1f2jeloxwhnj30fu0g0ta5.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/006gWxKPgw1f2jelpn9bdj30b40gkgmh.jpg",
                            @"http://ww1.sinaimg.cn/bmiddle/006gWxKPgw1f2jelriw1bj30fz0g175g.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/006gWxKPgw1f2jelt1kh5j30b10gmt9o.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/006gWxKPgw1f2jeluxjcrj30fw0fz0tx.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/006gWxKPgw1f2jelzxngwj30b20godgn.jpg",
                            @"http://ww2.sinaimg.cn/bmiddle/006gWxKPgw1f2jelwmsoej30fx0fywfq.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/006gWxKPgw1f2jem32ccrj30xm0sdwjt.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/006gWxKPgw1f2jelyhutwj30fz0fxwfr.jpg",],

                            @"thumbnail": @[@"http://ww2.sinaimg.cn/thumbnail/006gWxKPgw1f2jeloxwhnj30fu0g0ta5.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/006gWxKPgw1f2jelpn9bdj30b40gkgmh.jpg",
                            @"http://ww1.sinaimg.cn/thumbnail/006gWxKPgw1f2jelriw1bj30fz0g175g.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/006gWxKPgw1f2jelt1kh5j30b10gmt9o.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/006gWxKPgw1f2jeluxjcrj30fw0fz0tx.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/006gWxKPgw1f2jelzxngwj30b20godgn.jpg",
                            @"http://ww2.sinaimg.cn/thumbnail/006gWxKPgw1f2jelwmsoej30fx0fywfq.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/006gWxKPgw1f2jem32ccrj30xm0sdwjt.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/006gWxKPgw1f2jelyhutwj30fz0fxwfr.jpg",],

                            @"statusID": @"8",
                            @"commentList": @[@{@"from": @"SIZE潮流生活",
                            @"to": @"shanghai",
                            @"content": @"使用VVRichText适合包含文字、图片高性能的展示型界面的构建。"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"chengdu"]},

                    @{@"type": @"image",
                            @"name": @"someone",
                            @"avatar": @"http://tva4.sinaimg.cn/crop.0.0.700.700.50/006qdyzsjw8fashgddslaj30jg0jg0wb.jpg",
                            @"content": @"#GIF#少女时期的东方教主#林青霞#",
                            @"date": @"1459668442",

                            @"imgs": @[@"http://ww3.sinaimg.cn/bmiddle/006qdyzsly1fctmnzwqcwg307505pasc.gif"],
                            @"thumbnail": @[@"http://ww3.sinaimg.cn/thumbnail/006qdyzsly1fctmnzwqcwg307505pasc.gif"],

                            @"statusID": @"22",
                            @"commentList": @[@{@"from": @"someone",
                            @"to": @"wannnnnner",
                            @"content": @"支持GIF"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"kkkkkker"]},


                    @{@"type": @"image",
                            @"name": @"SIZE潮流生活",
                            @"avatar": @"http://tp2.sinaimg.cn/1829483361/50/5753078359/1",
                            @"content": @"近日[009][001][002][003][004][005][002]，adidas Originals😂为经典鞋款Stan Smith打造Primeknit版本，并带来全新的“OG”系列。简约的鞋身采用白色透气Primeknit针织材质制作，再将Stan Smith代表性的绿、红、深蓝三个元年色调融入到鞋舌和后跟点缀，最后搭载上米白色大底来保留其复古风味。据悉该鞋款将在今月登陆全球各大adidas Originals指定店舖。https://github.com/chinaxxren/VVRichText <-",
                            @"date": @"1459668442",

                            @"imgs": @[@"http://ww2.sinaimg.cn/bmiddle/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/6d0bb361gw1f2jim2hsg6j20lo0egwg2.jpg",
                            @"http://ww1.sinaimg.cn/bmiddle/6d0bb361gw1f2jim2d7nfj20lo0eg40q.jpg",
                            @"http://ww1.sinaimg.cn/bmiddle/6d0bb361gw1f2jim2hka3j20lo0egdhw.jpg",
                            @"http://ww2.sinaimg.cn/bmiddle/6d0bb361gw1f2jim2hq61j20lo0eg769.jpg"],

                            @"thumbnail": @[@"http://ww2.sinaimg.cn/thumbnail/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/6d0bb361gw1f2jim2hsg6j20lo0egwg2.jpg",
                            @"http://ww1.sinaimg.cn/thumbnail/6d0bb361gw1f2jim2d7nfj20lo0eg40q.jpg",
                            @"http://ww1.sinaimg.cn/thumbnail/6d0bb361gw1f2jim2hka3j20lo0egdhw.jpg",
                            @"http://ww2.sinaimg.cn/thumbnail/6d0bb361gw1f2jim2hq61j20lo0eg769.jpg"],


                            @"statusID": @"1",
                            @"commentList": @[@{@"from": @"SIZE潮流生活",
                            @"to": @"",
                            @"content": @"哈哈哈..."},
                            @{@"from": @"guangzhou",
                                    @"to": @"SIZE潮流生活",
                                    @"content": @"哈哈哈哈"},
                            @{@"from": @"SIZE潮流生活",
                                    @"to": @"shenzhen",
                                    @"content": @"使用VVRichText能保持滚动时的FPS在60hz"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"张学友", @"伊布拉希莫维奇", @"权志龙", @"郜林", @"扎克伯格"]},

                    @{@"type": @"website",
                            @"name": @"Ronaldo",
                            @"avatar": @"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
                            @"content": @"Easy to use yet capable of so much, iOS 9 was engineered to work hand in hand with the advanced technologies built into iPhone.",
                            @"date": @"1459668442",
                            @"imgs": @[@"http://ww2.sinaimg.cn/bmiddle/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg"],

                            @"thumbnail": @[@"http://ww2.sinaimg.cn/thumbnail/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg"],

                            @"detail": @"LWAlchemy,A fast and lightweight ORM framework for Cocoa and Cocoa Touch.",
                            @"statusID": @"1",
                            @"commentList": @[@{@"from": @"伊布拉西莫维奇",
                            @"to": @"",
                            @"content": @"手动再见..."}],
                            @"isLike": @(NO),
                            @"likeList": @[@"tiantian", @"VVRichText"]},


                    @{@"type": @"image",
                            @"name": @"妖妖小精",
                            @"avatar": @"http://tp2.sinaimg.cn/2185608961/50/5714822219/0",
                            @"content": @"出国留学的儿子为思念自己的家人们寄来一个用自己照片做成的人形立牌",
                            @"date": @"1459668442",
                            @"imgs": @[@"http://ww3.sinaimg.cn/bmiddle/8245bf01jw1f2jhh2ohanj20jg0yk418.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/8245bf01jw1f2jhh34q9rj20jg0px77y.jpg",
                            @"http://ww1.sinaimg.cn/bmiddle/8245bf01jw1f2jhh3grfwj20jg0pxn13.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/8245bf01jw1f2jhh3ttm6j20jg0el76g.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/8245bf01jw1f2jhh43riaj20jg0pxado.jpg",
                            @"http://ww2.sinaimg.cn/bmiddle/8245bf01jw1f2jhh4mutgj20jg0ly0xt.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/8245bf01jw1f2jhh4vc7pj20jg0px41m.jpg",],


                            @"thumbnail": @[@"http://ww3.sinaimg.cn/thumbnail/8245bf01jw1f2jhh2ohanj20jg0yk418.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/8245bf01jw1f2jhh34q9rj20jg0px77y.jpg",
                            @"http://ww1.sinaimg.cn/thumbnail/8245bf01jw1f2jhh3grfwj20jg0pxn13.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/8245bf01jw1f2jhh3ttm6j20jg0el76g.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/8245bf01jw1f2jhh43riaj20jg0pxado.jpg",
                            @"http://ww2.sinaimg.cn/thumbnail/8245bf01jw1f2jhh4mutgj20jg0ly0xt.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/8245bf01jw1f2jhh4vc7pj20jg0px41m.jpg",],

                            @"statusID": @"2",
                            @"commentList": @[@{@"from": @"炉石传说",
                            @"to": @"",
                            @"content": @"#炉石传说#"},
                            @{@"from": @"gamer",
                                    @"to": @"SIZE潮流生活",
                                    @"content": @"哈哈哈哈"},
                            @{@"from": @"SIZE潮流生活",
                                    @"to": @"styler",
                                    @"content": @"打得不错。"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"sky"]},

                    @{@"type": @"image",
                            @"name": @"Instagram热门",
                            @"avatar": @"",
                            @"content": @"Austin Butler & Vanessa Hudgens  想试试看扑到一个一米八几的人怀里是有多舒服[心]",
                            @"date": @"1459668442",

                            @"imgs": @[@"http://ww1.sinaimg.cn/bmiddle/005xpHs3gw1f2jg132p3nj309u0goq62.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/005xpHs3gw1f2jg14per3j30b40ctmzp.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/005xpHs3gw1f2jg14vtjjj30b40b4q5m.jpg",
                            @"http://ww1.sinaimg.cn/bmiddle/005xpHs3gw1f2jg15amskj30b40f1408.jpg",
                            @"http://ww3.sinaimg.cn/bmiddle/005xpHs3gw1f2jg16f8vnj30b40g4q4q.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/005xpHs3gw1f2jg178dxdj30am0gowgv.jpg",
                            @"http://ww2.sinaimg.cn/bmiddle/005xpHs3gw1f2jg17c5urj30b40ghjto.jpg"],

                            @"thumbnail": @[@"http://ww1.sinaimg.cn/thumbnail/005xpHs3gw1f2jg132p3nj309u0goq62.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/005xpHs3gw1f2jg14per3j30b40ctmzp.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/005xpHs3gw1f2jg14vtjjj30b40b4q5m.jpg",
                            @"http://ww1.sinaimg.cn/thumbnail/005xpHs3gw1f2jg15amskj30b40f1408.jpg",
                            @"http://ww3.sinaimg.cn/thumbnail/005xpHs3gw1f2jg16f8vnj30b40g4q4q.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/005xpHs3gw1f2jg178dxdj30am0gowgv.jpg",
                            @"http://ww2.sinaimg.cn/thumbnail/005xpHs3gw1f2jg17c5urj30b40ghjto.jpg"],


                            @"statusID": @"3",
                            @"commentList": @[@{@"from": @"Tom",
                            @"to": @"SIZE潮流生活",
                            @"content": @"哈哈哈哈"},
                            @{@"from": @"SIZE潮流生活",
                                    @"to": @"kkkk",
                                    @"content": @"+++"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"Tim Cook"]},


                    @{@"type": @"image",
                            @"name": @"头条新闻",
                            @"avatar": @"http://tp1.sinaimg.cn/1618051664/50/5735009977/0",
                            @"content": @"#万象# 【熊孩子！4名小学生铁轨上设障碍物逼停火车】4名小学生打赌，1人认为火车会将石头碾成粉末，其余3人不信，认为只会碾碎，于是他们将道碴摆放在铁轨上。火车司机发现前方不远处的铁轨上，摆放了影响行车安全的障碍物，于是紧急采取制动，列车中途停车13分钟。O4名学生铁轨上设障碍物逼停火车#mytags# nice",
                            @"date": @"1459668442",

                            @"imgs": @[@"http://ww2.sinaimg.cn/bmiddle/60718250jw1f2jg46smtmj20go0go77r.jpg"],

                            @"thumbnail": @[@"http://ww2.sinaimg.cn/thumbnail/60718250jw1f2jg46smtmj20go0go77r.jpg"],


                            @"statusID": @"4",
                            @"commentList": @[@{@"from": @"Tom",
                            @"to": @"SIZE潮流生活",
                            @"content": @"哈哈哈哈"},
                            @{@"from": @"SIZE潮流生活",
                                    @"to": @"ooooer",
                                    @"content": @"打得不错。"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"Tim Cook"]},


                    @{@"type": @"image",
                            @"name": @"Kindle中国",
                            @"avatar": @"http://tp1.sinaimg.cn/3262223112/50/5684307907/1",
                            @"content": @"#只限今日#《简单的逻辑学》作者D.Q.麦克伦尼在书中提出了28种非逻辑思维形式，抛却了逻辑学一贯的刻板理论，转而以轻松的笔触带领我们畅游这个精彩无比的逻辑世界；《蝴蝶梦》我错了，我曾以为付出自己就是爱你。全球公认20世纪伟大的爱情经典，大陆独家合法授权。",
                            @"date": @"",

                            @"imgs": @[@"http://ww2.sinaimg.cn/bmiddle/c2719308gw1f2hav54htyj20dj0l00uk.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/c2719308gw1f2hav47jn7j20dj0j341h.jpg"],

                            @"thumbnail": @[@"http://ww2.sinaimg.cn/thumbnail/c2719308gw1f2hav54htyj20dj0l00uk.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/c2719308gw1f2hav47jn7j20dj0j341h.jpg"],


                            @"statusID": @"6",
                            @"commentList": @[@{@"from": @"Kindle中国",
                            @"to": @"",
                            @"content": @"统一回复,使用VVRichText来快速构建图文混排界面。享受如丝般顺滑的滚动体验。"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"kkk"]},


                    @{@"type": @"image",
                            @"name": @"G-SHOCK",
                            @"avatar": @"http://tp3.sinaimg.cn/1595142730/50/5691224157/1",
                            @"content": @"就算平时没有时间，周末也要带着G-SHOCK到户外走走，感受大自然的满满正能量！",
                            @"date": @"1459668442",
                            @"imgs": @[@"http://ww2.sinaimg.cn/bmiddle/5f13f24ajw1f2hc1r6j47j20dc0dc0t4.jpg"],

                            @"thumbnail": @[@"http://ww2.sinaimg.cn/thumbnail/5f13f24ajw1f2hc1r6j47j20dc0dc0t4.jpg"],

                            @"statusID": @"7",
                            @"commentList": @[@{@"from": @"SIZE潮流生活",
                            @"to": @"",
                            @"content": @"使用VVRichText来快速构建图文混排界面。享受如丝般顺滑的滚动体验。"},
                            @{@"from": @"xxyyzz",
                                    @"to": @"SIZE潮流生活",
                                    @"content": @"哈哈哈哈"},
                            @{@"from": @"SIZE潮流生活",
                                    @"to": @"killer",
                                    @"content": @"打得不错。"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"okkkker"]},


                    @{@"type": @"image",
                            @"name": @"数字尾巴",
                            @"avatar": @"http://tp1.sinaimg.cn/1726544024/50/5630520790/1",
                            @"content": @"外媒 AndroidAuthority 日前曝光诺基亚首款回归作品 NOKIA A1 的渲染图，手机的外形很 N 记，边框控制的不错。这是一款纯正的 Android 机型，传闻手机将采用 5.5 英寸 1080P 屏幕，搭载骁龙 652，Android 6.0 系统，并使用了诺基亚自家的 Z 启动器，不过具体发表的时间还是未知。尾巴们你会期待吗？",
                            @"date": @"1459668442",
                            @"imgs": @[@"http://ww3.sinaimg.cn/bmiddle/66e8f898gw1f2jck6jnckj20go0fwdhb.jpg"],
                            @"thumbnail": @[@"http://ww3.sinaimg.cn/thumbnail/66e8f898gw1f2jck6jnckj20go0fwdhb.jpg"],

                            @"statusID": @"9",
                            @"commentList": @[@{@"from": @"SIZE潮流生活",
                            @"to": @"",
                            @"content": @"使用VVRichText来快速构建图文混排界面。享受如丝般顺滑的滚动体验。"},
                            @{@"from": @"xin",
                                    @"to": @"SIZE潮流生活",
                                    @"content": @"哈哈哈哈"},
                            @{@"from": @"SIZE潮流生活",
                                    @"to": @"wanger",
                                    @"content": @"打得不错。"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"keeer"]},


                    @{@"type": @"image",
                            @"name": @"欧美街拍XOXO",
                            @"avatar": @"http://tp4.sinaimg.cn/1708004923/50/1283204657/0",
                            @"content": @"3.31～4.2 肯豆",
                            @"date": @"1459668442",

                            @"imgs": @[@"http://ww2.sinaimg.cn/bmiddle/65ce163bjw1f2jdkd2hgjj20cj0gota8.jpg",
                            @"http://ww1.sinaimg.cn/bmiddle/65ce163bjw1f2jdkjdm96j20bt0gota9.jpg",
                            @"http://ww2.sinaimg.cn/bmiddle/65ce163bjw1f2jdkvwepij20go0clgnd.jpg",
                            @"http://ww4.sinaimg.cn/bmiddle/65ce163bjw1f2jdl2ao77j20ci0gojsw.jpg",],

                            @"thumbnail": @[@"http://ww2.sinaimg.cn/thumbnail/65ce163bjw1f2jdkd2hgjj20cj0gota8.jpg",
                            @"http://ww1.sinaimg.cn/thumbnail/65ce163bjw1f2jdkjdm96j20bt0gota9.jpg",
                            @"http://ww2.sinaimg.cn/thumbnail/65ce163bjw1f2jdkvwepij20go0clgnd.jpg",
                            @"http://ww4.sinaimg.cn/thumbnail/65ce163bjw1f2jdl2ao77j20ci0gojsw.jpg",],


                            @"statusID": @"10",
                            @"commentList": @[@{@"from": @"uuuuuer",
                            @"to": @"SIZE潮流生活",
                            @"content": @"哈哈哈哈"}],
                            @"isLike": @(NO),
                            @"likeList": @[@"balalala"]},
            ];

    return _feedDatas;
}

@end
