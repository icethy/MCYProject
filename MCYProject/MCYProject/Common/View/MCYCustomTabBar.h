//
//  MCYCustomTabBar.h
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCYCustomTabBarItem;
@protocol MCYCustomTabBarDelegate;

@interface MCYCustomTabBar : UIView

@property (nonatomic, strong) NSArray<MCYCustomTabBarItem *> *items;
@property (nonatomic, assign) id<MCYCustomTabBarDelegate> delegate;

@end

@protocol MCYCustomTabBarDelegate <NSObject>

- (void)tabBar:(MCYCustomTabBar*)tab didSelectItem:(MCYCustomTabBarItem*)item atIndex:(NSInteger)index;

@end
