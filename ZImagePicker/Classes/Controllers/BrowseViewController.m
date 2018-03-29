//
//  BrowseViewController.m
//  QTImagePickerProject
//
//  Created by zhujiayong on 15/11/3.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "BrowseViewController.h"
#import "BrowseViewCell.h"
#import "Constant.h"

@interface BrowseViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    BOOL isFirstLoadView;
    BOOL isHiddenViews;
}

@property (nonatomic, strong) UIView *topView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation BrowseViewController

#pragma mark - ViewController生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstLoadView = YES;
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    [self.layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:self.layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.autoresizesSubviews = YES;
    self.collectionView.contentMode = UIViewContentModeCenter;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor=[UIColor blackColor];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[BrowseViewCell class] forCellWithReuseIdentifier:@"BrowseViewCell"];

    [self.collectionView setContentOffset:CGPointMake(SCREEN_WIDTH*self.currentIndex, 0) animated:NO];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.topView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    //NSLog(@"dealloc is called! BrowseViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 初始化视图
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, 64)];
        _topView.backgroundColor = [UIColor clearColor];
        
        UIButton *backBarItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [backBarItem setImage:[UIImage z_loadImageFromBundleWithName:@"imagepicker_goback"] forState:UIControlStateNormal];
        [backBarItem addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:backBarItem];
    }
    return _topView;
}

#pragma mark - 响应事件处理
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectButton:(UIButton *)sender {
    NSInteger index = sender.tag;
    ALAssetModel *assetModel = self.dataSource[index];
    ImagePickerGroupModel *groupModel;
    
    for (ImagePickerGroupModel *model in [DataManager sharedDataManager].assetGroupArrayByAlbum) {
        if ([model.name isEqualToString:assetModel.groupName]) {
            groupModel = model;
        }
    }
    
    if ([[DataManager sharedDataManager].selectedAssetArray containsObject:assetModel]) {
        [[DataManager sharedDataManager].selectedAssetArray removeObject:assetModel];
        [groupModel.selectedAssetArray removeObject:assetModel];
    }
    else {
        [[DataManager sharedDataManager].selectedAssetArray addObject:assetModel];
        if ([DataManager sharedDataManager].maxCountOfSelected == 0 || [DataManager sharedDataManager].selectedAssetArray.count <= [DataManager sharedDataManager].maxCountOfSelected) {
            [groupModel.selectedAssetArray addObject:assetModel];
        }
    }
    if ([DataManager sharedDataManager].maxCountOfSelected == 0 || [DataManager sharedDataManager].selectedAssetArray.count <= [DataManager sharedDataManager].maxCountOfSelected) {
        [self.collectionView reloadData];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedAssetArrayChange" object:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BrowseViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BrowseViewCell" forIndexPath:indexPath];
    ALAssetModel *assetModel = self.dataSource[indexPath.section];
    ALAsset *asset = assetModel.asset;

    UIImage *img = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    cell.imgView.image = img;

    CGRect rect = [UIImage imageViewFrameWithSize:CGSizeMake(asset.defaultRepresentation.dimensions.width, asset.defaultRepresentation.dimensions.height)];
    if (rect.size.height > SCREEN_HEIGHT) {
        cell.imgView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    }
    else {
        cell.imgView.frame = rect;
    }
    cell.imgScrollView.contentSize = rect.size;
    
        [self loadFullScreenImage:cell];
        isFirstLoadView = NO;
    
    cell.selectedButton.tag = indexPath.section;
    [cell.selectedButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isSelected = [[DataManager sharedDataManager].selectedAssetArray containsObject:assetModel];
    if (isSelected) {
        [cell.selectedButton setImage:nil forState:UIControlStateNormal];
        [cell.selectedButton setBackgroundImage:[UIImage z_loadImageFromBundleWithName:@"imagepicker_selected"] forState:UIControlStateNormal];
        NSUInteger indexAtArray = [[DataManager sharedDataManager].selectedAssetArray indexOfObject:assetModel];
        [cell.selectedButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)indexAtArray+1] forState:UIControlStateNormal];
    }
    else {
        [cell.selectedButton setImage:[UIImage z_loadImageFromBundleWithName:@"imagepicker_normal"] forState:UIControlStateNormal];
        [cell.selectedButton setBackgroundImage:nil forState:UIControlStateNormal];
        [cell.selectedButton setTitle:nil forState:UIControlStateNormal];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    isHiddenViews = !isHiddenViews;
    _topView.hidden = isHiddenViews;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFlagView" object:@(isHiddenViews)];
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return  [[UIScreen mainScreen] bounds].size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
    [self loadFullScreenImage:nil];
}

#pragma mark - 刷新视图处理
- (void)loadFullScreenImage:(BrowseViewCell *)cell {
    ALAssetModel *assetModel = self.dataSource[self.currentIndex];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger index = [self.dataSource indexOfObject:assetModel];
        ImagePickerImageModel *newImageModel = [self compressImageWith:assetModel index:index];

        if ([self isShouldUpdateImage:index]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(cell == nil)
                {
                    BrowseViewCell *cell = self.collectionView.visibleCells.lastObject;
                    cell.imgView.image = newImageModel.image;
                }
                else {
                    cell.imgView.image = newImageModel.image;
                }
            });
        }
    });
}

- (BOOL)isShouldUpdateImage:(NSInteger)index {
    NSInteger i = self.collectionView.contentOffset.x/SCREEN_WIDTH;
    ALAssetModel *assetModel = self.dataSource[i];
    NSInteger currenIndex = [self.dataSource indexOfObject:assetModel];
    if (index == currenIndex && index == self.currentIndex && !self.collectionView.dragging) {
        return YES;
    }
    return NO;
}

//读取图片，大于512k时进行压缩
- (ImagePickerImageModel *)compressImageWith:(ALAssetModel *)assetModel index:(NSInteger)index {
    if (self.collectionView.dragging) {
        return nil;
    }
//    // maxPixelSize 最大kb
//    UIImage *newImage;
//    if ([assetModel.asset defaultRepresentation].size/1024.00 > 512.00) {
//        newImage = [UIImage thumbnailForAsset:assetModel.asset maxPixelSize:MaxPixelSize];
//    }
//    else {
//        newImage = [UIImage imageWithCGImage:assetModel.asset.defaultRepresentation.fullScreenImage];
//    }
//    ImagePickerImageModel *model = [[ImagePickerImageModel alloc] init];
//    model.image = newImage;
//    model.index = index;
//    return model;
    
    //为了支持长图
    UIImage *tempImg = nil;
    ALAssetRepresentation *image_representation = [assetModel.asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc(image_representation.size);
    NSUInteger length = [image_representation getBytes:buffer fromOffset: 0.0 length:image_representation.size error:nil];
    if (length != 0)  {
        NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:image_representation.size freeWhenDone:YES];
        tempImg = [UIImage imageWithData:adata];
    }
    ImagePickerImageModel *model = [[ImagePickerImageModel alloc] init];
    model.image = tempImg;
    model.index = index;
    return model;
}

@end
