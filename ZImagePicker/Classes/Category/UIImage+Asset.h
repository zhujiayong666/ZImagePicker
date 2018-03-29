//
//  UIImage+Asset.h
//  QTImagePickerProject
//
//  Created by zhujiayong on 15/11/11.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface UIImage (Asset)

//读取相册资源的图片，指定最大值
+ (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(CGFloat)size;

//计算图片的适合大小
+ (CGRect)imageViewFrameWithSize:(CGSize)size;

//加载本地图片
+ (UIImage *)z_loadImageFromBundleWithName:(NSString *)name;

+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;

@end
