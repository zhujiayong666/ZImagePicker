//
//  GroupListCell.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "GroupListCell.h"
#import "Constant.h"

@implementation GroupListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 65, 65)];
        [self.contentView addSubview:self.imgView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 0, 50, 75)];
        [self.contentView addSubview:self.nameLabel];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(145, 0, 50, 75)];
        self.countLabel.textColor = [UIColor colorWithWhite:0.498 alpha:1.000];
        [self.contentView addSubview:self.countLabel];
        
        UIImage *img = [UIImage z_loadImageFromBundleWithName:@"imagepickerGroup_selectedamount"];
        self.selectedCountButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - 35, 22.5, 30, 30)];
        self.selectedCountButton.userInteractionEnabled = NO;
        [self.selectedCountButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.selectedCountButton setBackgroundImage:img forState:UIControlStateNormal];
        [self.contentView addSubview:self.selectedCountButton];
        
        self.arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 12 - 20, (CGRectGetHeight(self.contentView.frame)-12)/2, 12, 12)];
        [self.arrowView setImage:[UIImage z_loadImageFromBundleWithName:@"cell_right_arrow"]];
        [self.contentView addSubview:self.arrowView];
        
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetHeight(self.contentView.frame)-.5, CGRectGetWidth(self.contentView.frame) - CGRectGetMinX(self.nameLabel.frame), .5)];
        self.lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.lineView];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.arrowView.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 12 - 20, (CGRectGetHeight(self.contentView.frame)-12)/2, 12, 12);
    self.lineView.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetHeight(self.contentView.frame)-.5, CGRectGetWidth(self.contentView.frame) - CGRectGetMinX(self.nameLabel.frame), .5);
}
@end
