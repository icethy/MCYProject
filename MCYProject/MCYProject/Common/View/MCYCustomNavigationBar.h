//
//  MCYCustomNavigationBar.h
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCYCustomNavigationBar : UIView

@property (nonatomic,copy) NSString *title;

@property (nonatomic,strong) UIImage *leftImage;
@property (nonatomic,strong) UIImage *rightImage;

@property (nonatomic,copy) NSString *leftTitle;
@property (nonatomic,copy) NSString *rightTitle;

@property (nonatomic,copy) void(^leftButtonClicked)();
@property (nonatomic,copy) void(^rightButtonClicked)();

- (void)setTitleView:(UIView*)titleView;
- (void)setLeftView:(UIView*)leftView;
- (void)setRightView:(UIView*)rightView;

- (void)setBackgroundImage:(UIImage*)image;

@end
