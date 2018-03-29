//
//  Constant.h
//  QTImagePickerProject
//
//  Created by zhujiayong on 15/10/26.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#import "BaseImagePickerViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "UIImage+Asset.h"

#define SCREEN_WIDTH    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT   ([[UIScreen mainScreen] bounds].size.height)
#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self;
#define IOS7_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] intValue] >= 7) ? YES : NO)

#define MaxPixelSize 1024 //默认读取系统相册最大值
#endif /* Constant_h */
