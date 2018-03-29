//
//  BrowseViewCell.m
//  QTImagePickerProject
//
//  Created by zhujiayong on 15/11/3.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "BrowseViewCell.h"
#import "Constant.h"

@implementation BrowseViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imgScrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.contentView addSubview:self.imgScrollView];

        self.imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        [self.imgView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imgScrollView addSubview:self.imgView];
        
        self.selectedButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 35, 7, 30, 30)];
        [self.selectedButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [self.selectedButton setBackgroundImage:[UIImage z_loadImageFromBundleWithName:@"imagepicker_normal"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.selectedButton];
    }
    return self;
}

@end
