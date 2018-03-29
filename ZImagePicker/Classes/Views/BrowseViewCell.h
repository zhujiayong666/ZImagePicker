//
//  BrowseViewCell.h
//  QTImagePickerProject
//
//  Created by zhujiayong on 15/11/3.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseViewCell : UICollectionViewCell

@property (nonatomic, strong) UIScrollView *imgScrollView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *selectedButton;

@end

