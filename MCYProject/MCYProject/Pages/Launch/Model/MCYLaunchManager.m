//
//  MCYLaunchManager.m
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYLaunchManager.h"
#import "MCYLoginViewController.h"
#import "MCYTabBarController.h"

#import "TestViewController.h"

@interface MCYLaunchManager ()

@property (nonatomic, strong) UINavigationController *loginViewController;
@property (nonatomic, strong) MCYTabBarController *mainTabViewController;

@end

@implementation MCYLaunchManager

+ (instancetype)sharedManager
{
    static MCYLaunchManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MCYLaunchManager alloc] init];
    });
    return manager;
}

- (void)showMainTabView
{
    GCDMain(^{
        [[UIApplication sharedApplication].keyWindow setRootViewController:self.mainTabViewController];
        self.loginViewController = nil;
    });
}

- (void)showLoginView
{
    GCDMain(^{
        [[UIApplication sharedApplication].keyWindow setRootViewController:self.loginViewController];
        self.mainTabViewController = nil;
    });
}

#pragma mark - Setter & Getter

- (UINavigationController*)loginViewController
{
    if (!_loginViewController) {
        MCYLoginViewController *loginVC = [[MCYLoginViewController alloc] init];
        _loginViewController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    }
    
    return _loginViewController;
}

- (MCYTabBarController*)mainTabViewController
{
    if (!_mainTabViewController) {
        _mainTabViewController = [MCYTabBarController createTabBarController:^MCYTabBarConfig *(MCYTabBarConfig *config) {
            
            TestViewController *findVC = [[TestViewController alloc] init];
            UINavigationController * findNav = [[UINavigationController alloc] initWithRootViewController:findVC]; // 发现
            
            TestViewController *footprintsVC = [[TestViewController alloc] init];
            UINavigationController * footprintsNav = [[UINavigationController alloc] initWithRootViewController:footprintsVC]; // 足迹
            
            TestViewController * arVC = [[TestViewController alloc] init];
            UINavigationController * arNav = [[UINavigationController alloc] initWithRootViewController:arVC]; // AR
            
            TestViewController *newsVC = [[TestViewController alloc] init];
            UINavigationController * newsNav = [[UINavigationController alloc] initWithRootViewController:newsVC]; // 消息
            
            TestViewController *personalVC = [[TestViewController alloc] init];
            UINavigationController * personalNav = [[UINavigationController alloc] initWithRootViewController:personalVC]; // 我的
            
            config.viewControllers = @[findNav, footprintsNav, arNav, newsNav, personalNav];
            config.normalImages = @[@"tab_faxian", @"tab_zuji", @"tab_AR", @"tab_xiaoxi", @"tab_wode"];
            config.selectedImages = @[@"tab_faxian_click", @"tab_zuji", @"tab_AR", @"tab_xiaoxi_click", @"tab_wode_click"];
            config.titles = @[@"发现", @"足迹", @"AR", @"消息", @"我的"];
            config.selectedColor = [UIColor colorWithHexString:@"262626"];
            config.normalColor = [UIColor colorWithHexString:@"9b9b9b"];
            
            return config;
        }];
    }
    return _mainTabViewController;
}

@end
