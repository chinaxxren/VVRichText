//
// Created by Jiangmingz on 2019-06-13.
// Copyright (c) 2019 Jiangmingz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedWidgetCollect;
@class StatusDto;


@interface FeedVM : NSObject

@property(nonatomic, strong) NSMutableArray *datas;

- (void)loadData;

- (FeedWidgetCollect *)viewDtoWithStatusModel:(StatusDto *)statusModel index:(NSInteger)index;

- (void)expendData:(NSInteger)index;

@end