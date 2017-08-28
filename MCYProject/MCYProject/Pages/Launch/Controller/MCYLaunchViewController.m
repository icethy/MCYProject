//
//  MCYLaunchViewController.m
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYLaunchViewController.h"
#import "MCYLaunchManager.h"

@interface MCYLaunchViewController ()

@end

@implementation MCYLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - UI
- (void)buildUI
{
    // 根据登录状态显示 登录页还是主页
    [[MCYLaunchManager sharedManager] showMainTabView];
}

@end
