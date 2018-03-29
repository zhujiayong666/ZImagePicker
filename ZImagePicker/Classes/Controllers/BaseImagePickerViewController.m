//
//  BaseImagePickerViewController.m
//  QTImagePickerProject
//
//  Created by 朱家永 on 15/10/24.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import "BaseImagePickerViewController.h"
#import "ZImagePickerViewController.h"

@interface BaseImagePickerViewController ()
@end

@implementation BaseImagePickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        [self addRightItem];
    }
    return self;
}

#pragma mark - Cancel Button
- (void)addRightItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemAction {
    ZImagePickerViewController *navi = (ZImagePickerViewController *) self.navigationController;
    [navi dismiss];
}

@end
