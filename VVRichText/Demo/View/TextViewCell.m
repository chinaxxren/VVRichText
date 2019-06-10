//
//  TextViewCell.m
//  VVAsyncDisplayViewDemo
//
//  Created by Jiangmingz on 2018/7/26.
//  Copyright © 2018年 WayneInc. All rights reserved.
//

#import "TextViewCell.h"


@interface TextViewCell ()

@property(nonatomic, strong) VVAsyncDisplayView *displayView;

@end

@implementation TextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.displayView = [[VVAsyncDisplayView alloc] initWithFrame:CGRectZero];
        self.displayView.backgroundColor = [UIColor yellowColor];
        self.displayView.displaysAsynchronously = YES;
        [self.contentView addSubview:self.displayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.displayView.frame = self.bounds;
}

- (void)setLayout:(VVLayout *)layout {
    if (_layout != layout) {
        _layout = layout;

        self.displayView.layout = self.layout;
    }
}

@end
