//
//  SelectImagesViewController.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "SelectImagesViewController.h"
#import "XLPlainFlowLayout.h"
#import "SelectImageViewCell.h"
#import "HeaderReusableView.h"
#import "BrowseViewController.h"

@interface SelectImagesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    BOOL _isNeedSetContentOffsetY;
    NSInteger _maxCount;
}

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *dataSourceOfGroup;// 按日期分组

@property (nonatomic, strong) XLPlainFlowLayout *layout;
@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation SelectImagesViewController

#pragma mark - ViewController生命周期
- (instancetype)init
{
    self = [super init];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && SCREEN_WIDTH>SCREEN_HEIGHT) {
            _maxCount = 7;
        }
        else {
            _maxCount = 4;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView:) name:@"selectedAssetArrayChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView:) name:@"isGroupChange" object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isNeedSetContentOffsetY = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //NSLog(@"dealloc is called! SelectImagesViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 初始化视图
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-44-64) collectionViewLayout:self.layout];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[SelectImageViewCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[HeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    }
    return _collectionView;
}

- (XLPlainFlowLayout *)layout {
    if (!_layout) {
        _layout = [[XLPlainFlowLayout alloc] init];
    }
    return _layout;
}

#pragma mark - 初始化数据
- (void)setGroupModel:(ImagePickerGroupModel *)groupModel {
    _groupModel = groupModel;
    _isNeedSetContentOffsetY = YES;
    self.navigationItem.title = _groupModel.name;
    if ([DataManager sharedDataManager].isGroup) {
        self.dataSourceOfGroup = _groupModel.assetArray;
    }
    else {
        self.dataSource = _groupModel.assetArray;
    }
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    CGFloat height = [self getContentOffsetY:NO];
    if (![DataManager sharedDataManager].isGroup) {
        [self reloadCollectionViewWithHeight:height];
    }
}

- (void)setDataSourceOfGroup:(NSMutableArray *)dataSourceOfGroup {
    __weak SelectImagesViewController *weakSelf = self;

    if (_dataSourceOfGroup.count > 0) {
        CGFloat height = [self getContentOffsetY:YES];
        [self reloadCollectionViewWithHeight:height];
    }
    else {
        dispatch_queue_t myQueue = dispatch_queue_create("data.zhujy.com", NULL);
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(myQueue, ^{
        _dataSourceOfGroup = [[DataManager sharedDataManager] groupingSortingWithSourceArray:dataSourceOfGroup];
        CGFloat height = [weakSelf getContentOffsetY:YES];
        dispatch_async(mainQueue, ^{
                if ([DataManager sharedDataManager].isGroup) {
                    [weakSelf reloadCollectionViewWithHeight:height];
                }
            });
        });
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([DataManager sharedDataManager].isGroup) {
        ImagePickerGroupModel *groupModel = _dataSourceOfGroup[section];
        return groupModel.assetArray.count;
    }
    return _dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([DataManager sharedDataManager].isGroup) {
        return _dataSourceOfGroup.count;
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    ALAssetModel *assetModel;
    if ([DataManager sharedDataManager].isGroup) {
        ImagePickerSubGroupModel *subGroupModel = _dataSourceOfGroup[indexPath.section];
        assetModel = subGroupModel.assetArray[indexPath.row];
    }
    else {
        assetModel = _dataSource[indexPath.row];
    }
    
    ALAsset *asset = assetModel.asset;
    BOOL isSelected = [[DataManager sharedDataManager].selectedAssetArray containsObject:assetModel];
    cell.layerView.hidden = !isSelected;
    UIImage *imageCell = [UIImage imageWithCGImage:asset.thumbnail];
    cell.imgView.image = imageCell;
    cell.selectedButton.tag = indexPath.section*100000 + indexPath.row;
    [cell.selectedButton addTarget:self action:@selector(OneSelectButton:) forControlEvents:UIControlEventTouchUpInside];
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

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (![DataManager sharedDataManager].isGroup) {
        return nil;
    }
    HeaderReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.600];

        reusableView.button.tag = indexPath.section;
        [reusableView.button addTarget:self action:@selector(AllSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        
        ImagePickerSubGroupModel *subGroupModel = _dataSourceOfGroup[indexPath.section];
        reusableView.label.text = subGroupModel.dateStr;
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ALAssetModel *assetModel;
    if ([DataManager sharedDataManager].isGroup) {
        ImagePickerSubGroupModel *subGroupModel = _dataSourceOfGroup[indexPath.section];
        assetModel = subGroupModel.assetArray[indexPath.row];
    } else {
        assetModel = _dataSource[indexPath.row];
    }

    NSInteger index = 0;
    if ([[DataManager sharedDataManager].allAssetArray containsObject:assetModel]) {
        index = [[DataManager sharedDataManager].allAssetArray indexOfObject:assetModel];
    }
    
    BrowseViewController *browseVC = [[BrowseViewController alloc] init];
    browseVC.currentIndex = index;
    browseVC.dataSource = [DataManager sharedDataManager].allAssetArray;
    [self.navigationController pushViewController:browseVC animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isNeedSetContentOffsetY = NO;
}

#pragma mark - UICollectionViewDelegate
//每个view的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = (SCREEN_WIDTH-5*(_maxCount+1))/_maxCount;
    return  CGSizeMake(size, size);
}

//每个view的边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

//同一行cell之间的间距
-(CGFloat )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.5;
}

//同一列cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

#pragma mark - 处理选择图片
// 单张选择
- (void)OneSelectButton:(UIButton *)sender {
    _isNeedSetContentOffsetY = NO;
    NSInteger section = sender.tag/100000;
    NSInteger row = sender.tag%100000;
    ALAssetModel *assetModel;
    if ([DataManager sharedDataManager].isGroup) {
        ImagePickerSubGroupModel *subGroupModel = _dataSourceOfGroup[section];
        assetModel = subGroupModel.assetArray[row];
    } else {
        assetModel = _dataSource[row];
    }
    
    if ([[DataManager sharedDataManager].selectedAssetArray containsObject:assetModel]) {
        [[DataManager sharedDataManager].selectedAssetArray removeObject:assetModel];
        [self.groupModel.selectedAssetArray removeObject:assetModel];
    }
    else {
        [self AddAssetToArray:assetModel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedAssetArrayChange" object:nil];
}

// 全组选择
- (void)AllSelectButton:(UIButton *)sender {
    _isNeedSetContentOffsetY = NO;
    NSInteger section = sender.tag;
    ImagePickerSubGroupModel *subGroupModel = _dataSourceOfGroup[section];
    
    //0:都不存在；1:部分存在；2:全部存在
    BOOL isExistZero = NO;
    BOOL isExistAll = NO;
    for (ALAssetModel *assetModel in subGroupModel.assetArray) {
        if ([[DataManager sharedDataManager].selectedAssetArray containsObject:assetModel]) {
            isExistAll = YES;
        }
        else {
            isExistZero = YES;
        }
        
        if (isExistZero && isExistAll) {
            break;
        }
    }
    
    if (isExistAll == NO) {
        for (ALAssetModel *assetModel in subGroupModel.assetArray) {
            [self AddAssetToArray:assetModel];
        }
    }
    else if (isExistZero == NO) {
        for (ALAssetModel *assetModel in subGroupModel.assetArray) {
            [[DataManager sharedDataManager].selectedAssetArray removeObject:assetModel];
            [self.groupModel.selectedAssetArray removeObject:assetModel];
        }
    }
    else {
        for (ALAssetModel *assetModel in subGroupModel.assetArray) {
            if (![[DataManager sharedDataManager].selectedAssetArray containsObject:assetModel]) {
                [self AddAssetToArray:assetModel];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedAssetArrayChange" object:nil];
}

- (void)AddAssetToArray:(ALAssetModel *) assetModel {
    [[DataManager sharedDataManager].selectedAssetArray addObject:assetModel];
    if ([DataManager sharedDataManager].maxCountOfSelected==0 || [DataManager sharedDataManager].selectedAssetArray.count <= [DataManager sharedDataManager].maxCountOfSelected) {
        [self.groupModel.selectedAssetArray addObject:assetModel];
    }
}

#pragma mark - 处理视图刷新

- (void)reloadCollectionView:(NSNotification *)notification {
    if (notification.object) {
        [DataManager sharedDataManager].isGroup = [notification.object boolValue];
    }
    if ([DataManager sharedDataManager].isGroup) {
        self.dataSourceOfGroup = _groupModel.assetArray;
    }
    else {
        self.dataSource = _groupModel.assetArray;
    }
}

- (void)reloadCollectionViewWithHeight:(CGFloat)height {
    __weak SelectImagesViewController *weakSelf = self;
    [UIView animateWithDuration:0 animations:^{
        self.layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, [DataManager sharedDataManager].isGroup?50:0);
        [weakSelf.collectionView reloadData];
    }];
    if (height > SCREEN_HEIGHT-44 && _isNeedSetContentOffsetY) {
        self.collectionView.contentOffset = CGPointMake(0, height - SCREEN_HEIGHT + 64 + 44);
    }
}

- (CGFloat)getContentOffsetY:(BOOL)isGroup {
    CGFloat height = 0;
    if (isGroup) {
        height = _dataSourceOfGroup.count * 50;//header
        for (ImagePickerSubGroupModel *subGroupModel in _dataSourceOfGroup) {
            NSInteger row = subGroupModel.assetArray.count/_maxCount;
            if (subGroupModel.assetArray.count%_maxCount>0) {
                row += 1;
            }
            height += row * (10 + (SCREEN_WIDTH-5*(_maxCount+1))/_maxCount);
        }
    }
    else {
        NSInteger row = _dataSource.count/_maxCount;
        if (_dataSource.count%_maxCount>0) {
            row += 1;
        }
        height = row * (10 + (SCREEN_WIDTH-5*(_maxCount+1))/_maxCount);
    }
    return height;
}

@end
