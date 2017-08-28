//
//  MCYLaunchManager.h
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCYLaunchManager : NSObject

+ (instancetype _Nullable )sharedManager;

- (void)showMainTabView;
- (void)showLoginView;

@end
