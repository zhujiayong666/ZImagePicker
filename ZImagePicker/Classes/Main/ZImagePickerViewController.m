//
//  ZImagePickerViewController.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "ZImagePickerViewController.h"
#import "RootImageViewController.h"
#import "SelectImagesViewController.h"
#import "BrowseViewController.h"
#import "DataManager.h"

@interface ZImagePickerViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *preViewBtn;
@property (nonatomic, strong) UIButton *isGroupBtn;
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) UIButton *redDotBtn;
@property (nonatomic, strong) UIButton *circleBtn;
@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) UIButton *originalBtn;
@property (nonatomic, strong) UIWindow *window;

@end

@implementation ZImagePickerViewController

#pragma mark - ViewController生命周期
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([NSStringFromClass([viewController class]) isEqualToString:@"BrowseViewController"]) {
        [navigationController setNavigationBarHidden:YES animated:animated];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];

        self.preViewBtn.hidden = YES;
        self.isGroupBtn.hidden = YES;
        [self.okBtn setEnabled:YES];
        self.originalBtn.frame = CGRectMake(10, 0, 120, 44);
    }
    else {
        [navigationController setNavigationBarHidden:NO animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        self.preViewBtn.hidden = NO;
        self.isGroupBtn.hidden = NO;
        self.originalBtn.hidden = NO;
        [self updateSubViews:nil];
        self.originalBtn.frame = CGRectMake(CGRectGetMaxX(self.preViewBtn.frame) + 10, 0, 120, 44);
    }

    self.isGroupBtn.enabled = ![NSStringFromClass([viewController class]) isEqualToString:@"RootImageViewController"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tintColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBottomToolView];
    [self.navigationBar setTintColor:self.tintColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSubViews:) name:@"updateFlagView" object:nil];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"相册";
    self.navigationItem.backBarButtonItem = backItem;
    
    __weak ZImagePickerViewController *weakSelf = self;
    self.delegate = weakSelf;

    RootImageViewController *rootVC = [[RootImageViewController alloc] init];
    rootVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:nil];

    SelectImagesViewController *selectVC = [[SelectImagesViewController alloc] init];
    self.viewControllers = @[rootVC, selectVC];
    DataManager *data = [DataManager sharedDataManager];
    data.maxCountOfSelected = self.maxCountOfSelected;
    [data loadAllData];
    data.finishBlock =  ^() {
        BOOL isFind = NO;
        for (int i=0; i<[DataManager sharedDataManager].assetGroupArrayByAlbum.count; i++) {
            ImagePickerGroupModel *groupModel = [DataManager sharedDataManager].assetGroupArrayByAlbum[i];
            if ([groupModel.name isEqualToString:@"相机胶卷"]) {
                isFind = YES;
                weakSelf.navigationItem.title = @"相机胶卷";
                selectVC.groupModel = groupModel; //第一次加载，默认为相册胶卷
                break;
            }
            if ([groupModel.name isEqualToString:@"所有照片"]) {
                isFind = YES;
                weakSelf.navigationItem.title = @"所有照片";
                selectVC.groupModel = groupModel; //第一次加载，默认为相册胶卷
                break;
            }
        }
        
        if(!isFind){
            ImagePickerGroupModel *groupModel =[DataManager sharedDataManager].assetGroupArrayByAlbum.lastObject;
            weakSelf.navigationItem.title = groupModel.name;
            selectVC.groupModel = groupModel; //第一次加载，默认为相册胶卷
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //NSLog(@"dealloc is called! ZImagePickerViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 初始化视图
- (void)addBottomToolView {
    self.bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44)];
    self.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0.965 alpha:1.000];
    [self.view addSubview:self.bottomContainerView];
    
    [self.bottomContainerView addSubview:self.isGroupBtn];
    [self.bottomContainerView addSubview:self.preViewBtn];
    [self.bottomContainerView addSubview:self.originalBtn];
    [self.bottomContainerView addSubview:self.okBtn];
    [self.bottomContainerView addSubview:self.redDotBtn];
}

- (UIButton *)preViewBtn {
    if (!_preViewBtn) {
        _preViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.isGroupBtn.frame) + 20, 8.5, 60, 27)];
        [_preViewBtn setBackgroundColor:[UIColor whiteColor]];
        [_preViewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_preViewBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [_preViewBtn.layer setCornerRadius:4.0];
        [_preViewBtn.layer setMasksToBounds:YES];
        [_preViewBtn.layer setBorderWidth:1.0];
        _preViewBtn.enabled = NO;
        [_preViewBtn.layer setBorderColor:[UIColor colorWithRed:0.910 green:0.914 blue:0.910 alpha:1.000].CGColor];
        [_preViewBtn setTitleColor:[UIColor colorWithWhite:0.733 alpha:1.000] forState:UIControlStateNormal];
        [_preViewBtn addTarget:self action:@selector(preViewBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _preViewBtn;
}

- (UIButton *)originalBtn {
    if (!_originalBtn) {
        _originalBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.preViewBtn.frame) + 10, 0, 120, 44)];
        _originalBtn.backgroundColor = [UIColor colorWithWhite:0.965 alpha:1.000];
        [_originalBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_originalBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_originalBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_originalBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [_originalBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        [_originalBtn setImage:[UIImage z_loadImageFromBundleWithName:@"ImageSelectedOff"] forState:UIControlStateNormal];
        [_originalBtn setImage:[UIImage z_loadImageFromBundleWithName:@"ImageSelectedOn"] forState:UIControlStateSelected];
        [_originalBtn addTarget:self action:@selector(originalBtn:) forControlEvents:UIControlEventTouchUpInside];
        _originalBtn.enabled = NO;
    }
    return _originalBtn;
}

- (UIButton *)isGroupBtn {
    if (!_isGroupBtn) {
        _isGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 7, 30, 30)];
        [_isGroupBtn setImage:[UIImage z_loadImageFromBundleWithName:@"icon_photo_list"] forState:UIControlStateNormal];
        [_isGroupBtn setImage:[UIImage z_loadImageFromBundleWithName:@"icon_photo_list_click"] forState:UIControlStateNormal|UIControlStateHighlighted];
        [_isGroupBtn setImage:[UIImage z_loadImageFromBundleWithName:@"icon_photo_bigpicture"] forState:UIControlStateSelected];
        [_isGroupBtn setImage:[UIImage z_loadImageFromBundleWithName:@"icon_photo_bigpicture_click"] forState:UIControlStateSelected|UIControlStateHighlighted];
        
        [_isGroupBtn addTarget:self action:@selector(isGroupBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _isGroupBtn;
}

- (UIButton *)okBtn {
    if (!_okBtn) {
        _okBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40 - 15, 8.5, 40, 27)];
        _okBtn.enabled = NO;
        [_okBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_okBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [_okBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_okBtn setTitleColor:[UIColor colorWithRed:9.0/255.0 green:187.0/255.0 blue:7.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

- (UIButton *)redDotBtn {
    if (!_redDotBtn) {
        _redDotBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _redDotBtn.center = CGPointMake(self.okBtn.center.x - 30, self.okBtn.center.y);
        [_redDotBtn setBackgroundImage:[UIImage z_loadImageFromBundleWithName:@"imagepickerGroup_selectedamount"] forState:UIControlStateNormal];
        _redDotBtn.hidden = YES;
        [_redDotBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_redDotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _redDotBtn;
}

#pragma mark - 处理响应事件
- (void)syncBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)originalBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.originalBtn setTitle:[NSString stringWithFormat:@"原图(%@)",[self getAllOriginalSizeStr]] forState:UIControlStateNormal];
    }
    else {
        [self.originalBtn setTitle:@"原图" forState:UIControlStateNormal];
    }
}

- (void)isGroupBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isGroupChange" object:@(sender.selected)];
}

- (NSMutableArray *)selectedAsset:(NSMutableArray *)aLAssetModelArray {
    NSMutableArray *selectedAsset = [[NSMutableArray alloc] init];
    for (ALAssetModel *model in aLAssetModelArray) {
        [selectedAsset addObject:model.asset];
    }
    return selectedAsset;
}

- (void)okBtnClicked:(UIButton *)sender {
    if (self.selectImageDelegate && [self.selectImageDelegate respondsToSelector:@selector(imagePickerViewController:arrayOfAsset:isOriginal:)]) {
        BaseImagePickerViewController *lastVC = self.viewControllers.lastObject;
        if ([NSStringFromClass([lastVC class]) isEqualToString:@"BrowseViewController"]) {
            if ([DataManager sharedDataManager].selectedAssetArray.count > 0) {
                [self.selectImageDelegate imagePickerViewController:self arrayOfAsset:[self selectedAsset:[DataManager sharedDataManager].selectedAssetArray] isOriginal:self.originalBtn.selected];
            }
            else {
                BrowseViewController *browseVC = (BrowseViewController *)lastVC;
               
                if ([browseVC.dataSource count]>0 && [browseVC.dataSource count] >= browseVC.currentIndex) {
                    NSMutableArray *selectedPhotos = [@[browseVC.dataSource[browseVC.currentIndex]] mutableCopy];
                     [self.selectImageDelegate imagePickerViewController:self arrayOfAsset:[self selectedAsset:selectedPhotos] isOriginal:self.originalBtn.selected];
                }
            }
        }
        else {
            [self.selectImageDelegate imagePickerViewController:self arrayOfAsset:[self selectedAsset:[DataManager sharedDataManager].selectedAssetArray] isOriginal:self.originalBtn.selected];
        }
    }
    
    [self dismiss];
}

- (void)preViewBtnClicked:(UIButton *)sender {
    UIViewController *vc = self.viewControllers.lastObject;
    BrowseViewController *browseVC = [[BrowseViewController alloc] init];
    browseVC.currentIndex = 0;
    browseVC.dataSource = [[DataManager sharedDataManager].selectedAssetArray mutableCopy];
    [vc.navigationController pushViewController:browseVC animated:YES];
}

- (void)updateSubViews:(NSNotification *)notification {
    if (notification.object != nil) {
        return;
    }
    
    NSInteger count = [DataManager sharedDataManager].selectedAssetArray.count;
    if (count > 0) {
        [self.okBtn setSelected:YES];
        [self.preViewBtn.layer setBorderColor:[UIColor colorWithWhite:0.787 alpha:1.000].CGColor];
        [self.preViewBtn setTitleColor:[UIColor colorWithWhite:0.180 alpha:1.000] forState:UIControlStateNormal];
        if(self.originalBtn.selected) {
            [self.originalBtn setTitle:[NSString stringWithFormat:@"原图(%@)",[self getAllOriginalSizeStr]] forState:UIControlStateNormal];
        }
        self.redDotBtn.hidden = NO;
        self.preViewBtn.enabled = YES;
        self.originalBtn.enabled = YES;
        self.okBtn.enabled = YES;
        [self.redDotBtn setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
        [UIView animateWithDuration:.25
                         animations:^{
                             self.redDotBtn.transform = CGAffineTransformMakeScale(1.3, 1.3);
                         }
                         completion:^(BOOL finish) {
                             [UIView animateWithDuration:.25 animations:^{
                                 self.redDotBtn.transform = CGAffineTransformMakeScale(1, 1);
                             }];
                         }];
    }
    else {
        self.preViewBtn.enabled = NO;
        self.originalBtn.enabled = NO;
        [self.preViewBtn.layer setBorderColor:[UIColor colorWithRed:0.910 green:0.914 blue:0.910 alpha:1.000].CGColor];
        [self.preViewBtn setTitleColor:[UIColor colorWithWhite:0.733 alpha:1.000] forState:UIControlStateNormal];
        [self.originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        self.originalBtn.selected = NO;
        if ([NSStringFromClass([self.viewControllers.lastObject class]) isEqualToString:@"BrowseViewController"]) {
            self.okBtn.enabled = YES;
            [self.okBtn setSelected:YES];
        }
        else {
            self.okBtn.enabled = NO;
            [self.okBtn setSelected:NO];
        }
        self.redDotBtn.hidden = YES;
    }
}

// 读取全部原图大小
- (NSString *)getAllOriginalSizeStr {
    CGFloat size = 0.0;
    for (ALAssetModel *model in [DataManager sharedDataManager].selectedAssetArray) {
        size += [model.asset defaultRepresentation].size/1024;
    }
    NSString *sizeStr;
    if (size<1024) {
        sizeStr = [NSString stringWithFormat:@"%ldK",(long)size];
    }
    else if (size/1024<10){
        sizeStr = [NSString stringWithFormat:@"%.1fM",size/1024];
    }
    else {
        sizeStr = [NSString stringWithFormat:@"%ldM",(long)size/1024];
    }
    return sizeStr;
}

#pragma mark - 视图处理
- (void)show {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelNormal+1;
    self.window.hidden = NO;
    self.window.rootViewController = self;
    
    CGRect viewFrameBegin = self.view.frame;
    viewFrameBegin.origin.y = self.window.bounds.size.height;
    
    CGRect viewFrameEnd = viewFrameBegin;
    viewFrameEnd.origin.y = 0;
    
    self.view.frame = viewFrameBegin;
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:.2
                     animations:^{
                         weakSelf.view.frame = viewFrameEnd;
                     }
                     completion:^(BOOL finished) {
                         nil;
                     }];
}

- (void)dismiss {

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[DataManager sharedDataManager] cleanData];
    
    CGRect viewFrameBegin = self.view.frame;
    
    CGRect viewFrameEnd = viewFrameBegin;
    
    viewFrameEnd.origin.y = self.window.bounds.size.height;
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:.2
                     animations:^{
                         weakSelf.view.frame = viewFrameEnd;
                     }
                     completion:^(BOOL finished) {
                         [weakSelf dismissViewControllerAnimated:YES completion:nil];
                         weakSelf.window.rootViewController = nil;
                         weakSelf.window.hidden = YES;
                         weakSelf.window = nil;
                     }];
}

@end
