//
//  SelectImageViewCell.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/25.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "SelectImageViewCell.h"
#import "Constant.h"

@implementation SelectImageViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = 0.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && SCREEN_WIDTH>SCREEN_HEIGHT) {
            width = (SCREEN_WIDTH-5*8)/7.0;
        }
        else {
            width = (SCREEN_WIDTH-5*5)/4.0;
        }
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        [self.contentView addSubview:self.imgView];

        self.layerView = [[UIView alloc] initWithFrame:self.imgView.bounds];
        self.layerView.hidden = YES;
        self.layerView.userInteractionEnabled = NO;
        self.layerView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.405];
        [ self.contentView addSubview:self.layerView];
        
        self.selectedButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 35, 5, 30, 30)];
        [self.selectedButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [self.selectedButton setImage:[UIImage z_loadImageFromBundleWithName:@"imagepicker_normal"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.selectedButton];
    }
    return self;
}

@end
