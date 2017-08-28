//
//  MCYBaseViewController.m
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYBaseViewController.h"
#import "MCYCustomNavigationBar.h"

@interface MCYBaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation MCYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    __weak typeof(self) weakself;
    _customNavigationBar = [[MCYCustomNavigationBar alloc] init];
    _customNavigationBar.leftButtonClicked = ^{
        [weakself leftNavigaionButtonClicked];
    };
    _customNavigationBar.rightButtonClicked = ^{
        [weakself rightNavigaionButtonClicked];
    };
    _customNavigationBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_customNavigationBar];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)setHiddenCustomNavigation:(BOOL)hiddenCustomNavigation {
    _hiddenCustomNavigation = hiddenCustomNavigation;
    self.customNavigationBar.hidden = hiddenCustomNavigation;
}

- (CGFloat)navigationHeight {
    return 64.0;
}

- (void)setCustomNavigationLeftView:(UIView*)view {
    [self.customNavigationBar setLeftView:view];
}
- (void)setCustomNavigationRightView:(UIView*)view {
    [self.customNavigationBar setRightView:view];
}
- (void)setCustomNavigationCenterView:(UIView*)view {
    [self.customNavigationBar setTitleView:view];
}

- (void)setTitle:(NSString *)title {
    self.customNavigationBar.title = title;
}

- (void)setNavigationColor:(UIColor *)navigationColor {
    self.customNavigationBar.backgroundColor = navigationColor;
}

- (void)setNavigationImage:(UIImage *)navigationImage {
    [self.customNavigationBar setBackgroundImage:navigationImage];
}

- (void)setRightNavigationTitle:(NSString *)rightNavigationTitle {
    _rightNavigationTitle = rightNavigationTitle;
    self.customNavigationBar.rightTitle = rightNavigationTitle;
}

- (void)setLeftNavigationTitle:(NSString *)leftNavigationTitle {
    _leftNavigationTitle = leftNavigationTitle;
    self.customNavigationBar.leftTitle = leftNavigationTitle;
}

- (void)setLeftNavigationImage:(UIImage *)leftNavigationImage {
    self.customNavigationBar.leftImage = leftNavigationImage;
}

- (void)setRightNavigationImage:(UIImage *)rightNavigationImage {
    self.customNavigationBar.rightImage = rightNavigationImage;
}

- (void)leftNavigaionButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigaionButtonClicked {
    
}

@end
