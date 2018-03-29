//
//  DataManager.h
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>
#import "UIImage+Asset.h"
#import "Constant.h"

//按相册的分组
@interface ImagePickerGroupModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *assetArray;
@property (nonatomic, strong) NSMutableArray *selectedAssetArray; // 被勾选的Asset数据

@end

// 相册中按日期的分组
@interface ImagePickerSubGroupModel : NSObject

@property (nonatomic, strong) NSString *dateStr;
@property (nonatomic, strong) NSMutableArray *assetArray;

@end

// 相片
@interface ALAssetModel : NSObject

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) BOOL selected;

@end

// 相片
@interface ImagePickerImageModel : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger index;

@end

@interface DataManager : NSObject

@property (assign, nonatomic) BOOL isGroup; // 显示相册时是否按日分组

@property (nonatomic,assign) NSInteger maxCountOfSelected; // 可以选择最大张数

@property (copy, nonatomic) void (^finishBlock)(); // 读取数据完成的回调

@property (strong, nonatomic) NSMutableArray *allAssetArray; // 全部的Asset数据

@property (strong, nonatomic) NSMutableArray *assetGroupArrayByAlbum; // 全部的Asset已按相册分组数据,GroupModel

@property (strong, nonatomic) NSMutableArray *selectedAssetArray; // 被勾选的Asset数据

+ (instancetype)sharedDataManager;

/**
 *  读取系统相册的全部相片
 */
- (void)loadAllData;

- (void)cleanData;

// 对指定的组的asset进行按日期排序
- (NSMutableArray *)groupingSortingWithSourceArray:(NSArray *)assetArray;
@end
