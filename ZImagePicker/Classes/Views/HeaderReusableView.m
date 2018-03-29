//
//  HeaderReusableView.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/25.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "HeaderReusableView.h"
#import "Constant.h"

@implementation HeaderReusableView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, SCREEN_WIDTH/2, 50)];
        self.label.tag = 1000;
        self.label.textColor = [UIColor blackColor];
        [self addSubview:self.label];
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50 - 10, 0, 50, 50)];
        [self.button setTitle:@"全选" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor colorWithRed:0.169 green:0.320 blue:0.561 alpha:1.000] forState:UIControlStateNormal];
        [self.button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:self.button];

    }
    return self;
}
@end
