//
//  DataManager.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "DataManager.h"

@interface ImagePickerGroupModel()
@end
@implementation ImagePickerGroupModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedAssetArray = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

@interface ImagePickerSubGroupModel()
@end
@implementation ImagePickerSubGroupModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.assetArray = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

@interface ALAssetModel()
@end
@implementation ALAssetModel
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
@end

@interface ImagePickerImageModel()
@end
@implementation ImagePickerImageModel
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
@end

@interface DataManager()
@end

@implementation DataManager

static NSDateFormatter *df;

+ (instancetype)sharedDataManager {
    static DataManager *sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    return sharedDataManager;
}

- (void)checkSelectArray:(NSNotification *)notification {
    if (self.maxCountOfSelected>0 && self.selectedAssetArray.count > self.maxCountOfSelected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多选择%ld张",(long)self.maxCountOfSelected] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [self.selectedAssetArray removeObjectsInRange:NSMakeRange(self.maxCountOfSelected, self.selectedAssetArray.count-self.maxCountOfSelected)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFlagView" object:nil];
}

- (void)loadAllData {
    self.allAssetArray = [[NSMutableArray alloc] init];
    self.assetGroupArrayByAlbum = [[NSMutableArray alloc] init];
    self.selectedAssetArray = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSelectArray:) name:@"selectedAssetArrayChange" object:nil];

    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    __block ImagePickerGroupModel *groupModel = [[ImagePickerGroupModel alloc] init];
    __block ALAssetModel *assetModel = [[ALAssetModel alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //读取相册授权
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror) {
            NSLog(@"访问相册失败 = %@",myerror.localizedDescription);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location != NSNotFound) {
                NSLog(@"无法访问相册，请在'设置->定位服务'设置为打开状态");
            }
            else {
                NSLog(@"相册访问失败");
            }
        };
        
        //读取相册里的相片
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *relust, NSUInteger index, BOOL *stop) {
            if (relust != nil) {
                if ([[relust valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                    
                    assetModel = [[ALAssetModel alloc] init];
                    assetModel.asset = relust;
                    assetModel.groupName = groupModel.name;
        
                    [array addObject:assetModel];
                    [self.allAssetArray addObject:assetModel];
                }
            }
            else {
                if (array.count > 0) {
                    groupModel.assetArray = [array mutableCopy];
                    [self.assetGroupArrayByAlbum addObject:groupModel];
                }
                groupModel = [[ImagePickerGroupModel alloc] init];
                [array removeAllObjects];
            }
        };
        
        //读取像册组名
        ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                NSString *g = [NSString stringWithFormat:@"%@",group];//获取相薄组

                NSString *g1 = [g substringFromIndex:1];
                
                NSArray *array = [NSArray arrayWithArray:[g1 componentsSeparatedByString:@","]];
                
                NSString *g2 = [array objectAtIndex:0] ;
                
                NSArray *nameArray = [NSArray arrayWithArray:[g2 componentsSeparatedByString:@":"]];
                NSString *groupName = nameArray[1];
                if ([groupName isEqualToString:@"Camera Roll"]) {
                    groupName = @"相机胶卷";
                }
                groupModel.name = groupName;
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
            }
            else {
                if (self.finishBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.finishBlock();
                    });
                }
            }
        };
        
        //保证其他地方也能访问
        static ALAssetsLibrary *library;
        if (library == nil) {
            library= [[ALAssetsLibrary alloc] init];
        }
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:libraryGroupsEnumeration failureBlock:failureblock];
    });
}

- (NSMutableArray *)groupingSortingWithSourceArray:(NSArray *)assetArray {

    if (assetArray.count == 0) {
        return nil;
    }
    ALAssetModel *model = assetArray.firstObject;
    ALAsset *firstPhoto = model.asset;
    __block id currDate = [firstPhoto valueForProperty:ALAssetPropertyDate];

    NSDate *firstPhotoDate = (NSDate *)[firstPhoto valueForProperty:ALAssetPropertyDate];
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
    }
    df.dateFormat = @"yyyy-MM-dd";
    currDate = [df stringFromDate:firstPhotoDate];

    NSMutableArray *allAssetGroups = [NSMutableArray array];
    __block NSMutableArray *tmpGroup = [NSMutableArray array];
    
     [assetArray enumerateObjectsUsingBlock:^(ALAssetModel *model, NSUInteger idx, BOOL *stop) {
        ALAsset *obj = model.asset;
        id date = [obj valueForProperty:ALAssetPropertyDate];
        BOOL timeSame = NO;
        static NSDateFormatter *df;
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
        }
        df.dateFormat = @"yyyy-MM-dd";
        date = [df stringFromDate:date];
        timeSame = [currDate compare:date] == NSOrderedSame;

        if (timeSame) {
            [tmpGroup addObject:model];
        }
        else {
            ImagePickerSubGroupModel *subModel = [[ImagePickerSubGroupModel alloc] init];
            subModel.dateStr = currDate;
            subModel.assetArray = tmpGroup;
            [allAssetGroups addObject:subModel];
            currDate = date;
            tmpGroup = [NSMutableArray array];
            [tmpGroup addObject:model];
        }

    }];
    
    ImagePickerSubGroupModel *subModel = [[ImagePickerSubGroupModel alloc] init];
    subModel.dateStr = currDate;
    subModel.assetArray = tmpGroup;

    [allAssetGroups addObject:subModel];
    return allAssetGroups;
}

- (void)cleanData {
    self.isGroup = NO;
    self.maxCountOfSelected = 0;
    [self.allAssetArray removeAllObjects];
    [self.assetGroupArrayByAlbum removeAllObjects];
    [self.selectedAssetArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
