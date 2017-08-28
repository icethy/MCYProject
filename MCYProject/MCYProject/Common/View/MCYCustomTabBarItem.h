//
//  MCYCustomTabBarItem.h
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCYCustomTabBarItemDelegate;

typedef enum : NSUInteger {
    MCYTabBarItemTypeDefault,  // 默认显示文字和图片
    MCYTabBarItemTypeImage,    // 图片显示
    MCYTabBarItemTypeText,     // 文字显示
    MCYTabBarItemTypeImageFlow, // 图片悬浮在tabBar顶端
} MCYTabBarItemType;

@interface MCYCustomTabBarItem : UIView

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) MCYTabBarItemType type;

@property (nonatomic, assign) id<MCYCustomTabBarItemDelegate> delegate;

@end

@protocol MCYCustomTabBarItemDelegate <NSObject>

- (void)tabBarItem:(MCYCustomTabBarItem*)item didSelectIndex:(NSInteger)index;

@end
