//
//  BrowseViewController.h
//  QTImagePickerProject
//
//  Created by zhujiayong on 15/11/3.
//  Copyright © 2015年 朱家永. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger currentIndex;

@end
