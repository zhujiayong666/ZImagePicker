//
//  RootImageViewController.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "RootImageViewController.h"
#import "SelectImagesViewController.h"
#import "GroupListCell.h"

@interface RootImageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RootImageViewController

#pragma mark - ViewController生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.906 alpha:1.000];
    self.navigationItem.title = @"相册";
    DataManager *data = [[DataManager alloc] init];
    data.finishBlock =  ^(NSMutableArray *dictArray) {
        [self.tableView reloadData];
    };
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //NSLog(@"dealloc is called! RootImageViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 初始化视图
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 64) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor colorWithWhite:0.906 alpha:1.000];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithWhite:0.906 alpha:1.000];
        _tableView.tableFooterView = view;
    }
    return _tableView;
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataManager sharedDataManager].assetGroupArrayByAlbum.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"GroupListCellIdentifier";
    GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[GroupListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    ImagePickerGroupModel *groupModel = [DataManager sharedDataManager].assetGroupArrayByAlbum[indexPath.row];
    ALAssetModel *assetModel = groupModel.assetArray.lastObject;
    ALAsset *asset = assetModel.asset;
    UIImage *img = [UIImage imageWithCGImage:asset.thumbnail];
    cell.imgView.image = img;
    cell.nameLabel.text = groupModel.name;
    cell.countLabel.text = [NSString stringWithFormat:@"(%d)",(int)groupModel.assetArray.count];
    
    NSArray *selectedAssetArray = groupModel.selectedAssetArray;
    cell.selectedCountButton.hidden = !(selectedAssetArray.count > 0);
    [cell.selectedCountButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)selectedAssetArray.count] forState:UIControlStateNormal];
    
    CGFloat width = [self getSizeWithString:groupModel.name font:cell.nameLabel.font contentWidth:CGFLOAT_MAX contentHight:75].width;
    CGRect rect = cell.nameLabel.frame;
    rect.size.width = width;
    cell.nameLabel.frame = rect; 
    
    rect = cell.countLabel.frame;
    rect.origin.x = CGRectGetMaxX(cell.nameLabel.frame) + 5;
    cell.countLabel.frame = rect;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectImagesViewController *vc = [[SelectImagesViewController alloc] init];
    vc.groupModel = [DataManager sharedDataManager].assetGroupArrayByAlbum[indexPath.row];
    vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 视图处理
- (CGSize)getSizeWithString:(NSString *)string font:(UIFont *)font contentWidth:(CGFloat)width contentHight:(CGFloat)height {
    CGSize labelSize = CGSizeZero;
    if ([string length] == 0) {
        return labelSize;
    }
    if (IOS7_OR_ABOVE) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [string boundingRectWithSize:CGSizeMake((width ? width : MAXFLOAT), (height ? height : MAXFLOAT)) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);
    } else {
        labelSize = [string sizeWithFont:font constrainedToSize:CGSizeMake((width ? width : MAXFLOAT), (height ? height : MAXFLOAT)) lineBreakMode:NSLineBreakByCharWrapping];
    }
    return labelSize;
}
@end
