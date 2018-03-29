//
//  ZImagePickerViewController.h
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@class ZImagePickerViewController;

@protocol ZImagePickerViewControllerDelegate <NSObject>

/**
 *  选择完成后回调
 *
 *  @param viewController   ZImagePickerViewController
 *  @param arrayOfAsset     元素了自定义的model：ALAssetModel
 *  @param isOriginal       是否原图
 */
- (void)imagePickerViewController:(ZImagePickerViewController *)imagePickerViewController arrayOfAsset:(NSMutableArray <ALAsset *>*)arrayOfAsset isOriginal:(BOOL)isOriginal;

@end


@interface ZImagePickerViewController : UINavigationController

@property (nonatomic, weak) id <ZImagePickerViewControllerDelegate> selectImageDelegate;

@property (nonatomic, strong) UIColor *tintColor;

/**
 *  最大可选张数
 */
@property (nonatomic,assign) NSInteger maxCountOfSelected;

- (void)show;

- (void)dismiss;

@end
