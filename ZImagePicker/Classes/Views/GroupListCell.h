//
//  GroupListCell.h
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UIButton *selectedCountButton;

@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, strong) UIView *lineView;

@end
