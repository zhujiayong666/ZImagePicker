//
//  ZViewController.m
//  ZImagePicker
//
//  Created by 朱家永 on 03/29/2018.
//  Copyright (c) 2018 朱家永. All rights reserved.
//

#import "ZViewController.h"
#import <ZImagePicker/ZImagePickerViewController.h>

@interface ZViewController ()

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    btn.center = self.view.center;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"相册" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClicked:(UIButton *)sender {
    ZImagePickerViewController *vc = [[ZImagePickerViewController alloc] init];
    [vc show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
