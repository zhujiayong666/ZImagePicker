//
//  SelectImageViewCell.h
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/25.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectImageViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *layerView;
@property (nonatomic, strong) UIButton *selectedButton;
@end
