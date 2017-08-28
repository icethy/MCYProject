//
//  MCYTabBarController.m
//  MCYProject
//
//  Created by machunyan on 2017/7/27.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYTabBarController.h"
#import "MCYCustomTabBar.h"
#import "MCYCustomTabBarItem.h"

static CGFloat MCYCustomTabBarHeight = 49.0;

@interface MCYTabBarController () <MCYCustomTabBarDelegate,UITabBarControllerDelegate>

@property (nonatomic, strong) MCYCustomTabBar *customTabBar;
@property (nonatomic, strong) MCYTabBarConfig *config;

@end

@implementation MCYTabBarController

#pragma mark - Public Methods

+ (instancetype)createTabBarController:(tabBarBlock)block
{
    static MCYTabBarController *tabBar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tabBar = [[MCYTabBarController alloc] initWithBlock:block];
    });
    return tabBar;
}

+ (instancetype)defaultTabBarController
{
    return [MCYTabBarController createTabBarController:nil];
}

- (void)hiddenTabBarWithAnimation:(BOOL)isAnimation
{
    if (isAnimation) {
        [UIView animateWithDuration:0.2 animations:^{
            
            self.customTabBar.alpha = 0;
        }];
    } else {
        
        self.customTabBar.alpha = 0;
    }
}

- (void)showTabBarWithAnimation:(BOOL)isAnimation
{
    if (isAnimation) {
        [UIView animateWithDuration:0.2 animations:^{
            
            self.customTabBar.alpha = 1.0;
        }];
    } else {
        
        self.customTabBar.alpha = 1.0;
    }
}

#pragma mark - Private Methods

- (instancetype)initWithBlock:(tabBarBlock)block
{
    self = [super init];
    if (self) {
        MCYTabBarConfig *config = [[MCYTabBarConfig alloc] init];
        NSAssert(block, @"Param in the function, can not be nil");
        
        if (block) {
            _config = block(config);
        }
        
        NSAssert(_config.viewControllers, @"Param ‘viewController’ in the 'config', can not be nil");
        
        [self setupViewControllers];
        [self setupTabBar];
    }
    
    return self;
}

- (void)setupViewControllers
{
    if (_config.isNavigation) {
        NSMutableArray *vcs = [NSMutableArray arrayWithCapacity:_config.viewControllers.count];
        for (UIViewController *vc in _config.viewControllers) {
            if (![vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = [[UINavigationController alloc] init];
                [vcs addObject:nav];
            } else {
                [vcs addObject:vc];
            }
        }
        self.viewControllers = [vcs copy];
    } else {
        self.viewControllers = [_config.viewControllers copy];
    }
}

- (void)setupTabBar
{
    NSMutableArray *items = [NSMutableArray array];
    
    MCYTabBarItemType type;
    
    if ((_config.selectedImages.count > 0 || _config.normalImages.count > 0) && _config.titles.count > 0) {
        type = MCYTabBarItemTypeDefault;
    } else if ((_config.selectedImages.count > 0 || _config.normalImages.count > 0) && _config.titles.count <= 0) {
        
        type = MCYTabBarItemTypeImage;
    } else if ((_config.selectedImages.count <= 0 && _config.normalImages.count <= 0) && _config.titles.count > 0) {
        
        type = MCYTabBarItemTypeText;
    } else {
        
        type = MCYTabBarItemTypeDefault;
    }
    
    for (int i = 0; i < _config.viewControllers.count; i++) {
        MCYCustomTabBarItem *item = [[MCYCustomTabBarItem alloc] init];
        
        // 对中间按钮特殊处理
        if (i == 2) {
            item.type = MCYTabBarItemTypeImageFlow;
        } else {
            item.type = type;
        }
        
        if (i == 0) {
            
            item.icon = _config.selectedImages[i];
            if (_config.titles.count > 0) {
                item.titleColor = _config.selectedColor;
            }
        } else {
            
            item.icon = _config.normalImages[i];
            if (_config.titles.count > 0) {
                
                item.titleColor = _config.normalColor;
            }
        }
        
        if (i < _config.titles.count) {
            
            item.title = _config.titles[i];
        }
        
        [items addObject:item];
        item.tag = i;
    }
    
    // 隐藏掉系统的tabBar
    self.tabBar.hidden = YES;
    self.customTabBar.items = [items copy];
    self.customTabBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - MCYCustomTabBarHeight, CGRectGetWidth(self.view.frame), MCYCustomTabBarHeight);
    [self.view addSubview:self.customTabBar];
}

#pragma mark - Getter & Setter

- (MCYCustomTabBar*)customTabBar
{
    if (!_customTabBar) {
        _customTabBar = [[MCYCustomTabBar alloc] init];
        _customTabBar.delegate = self;
    }
    
    return _customTabBar;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.selectedIndex = 0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - didSelectedItemByIndex

-(void)didSelectedItemByIndex:(NSUInteger)selectedIndex
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    for (UIView *view in self.customTabBar.subviews) {
        if ([view isKindOfClass:[MCYCustomTabBarItem class]]) {
            [items addObject:view];
        }
    }
    MCYCustomTabBarItem *item = (MCYCustomTabBarItem*)items[selectedIndex];
    if(item){
        [self tabBar:[self customTabBar] didSelectItem:item atIndex:selectedIndex];
    }
}


#pragma mark - MCYCustomTabBarDelegate

- (void)tabBar:(MCYCustomTabBar *)tab didSelectItem:(MCYCustomTabBarItem *)item atIndex:(NSInteger)index
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    for (UIView *view in tab.subviews) {
        if ([view isKindOfClass:[MCYCustomTabBarItem class]]) {
            [items addObject:view];
        }
    }
    
    for (int i = 0; i < items.count; i++) {
        UIView *view = items[i];
        if ([view isKindOfClass:[MCYCustomTabBarItem class]]) {
            MCYCustomTabBarItem *item = (MCYCustomTabBarItem*)view;
            item.icon = self.config.normalImages[i];
            if (self.config.titles.count > 0) {
                
                item.titleColor = _config.normalColor;
            }
        }
    }
    
    item.icon = self.config.selectedImages[index];
    
    if (self.config.titles.count > 0) {
        
        item.titleColor = self.config.selectedColor;
    }
    
    self.selectedIndex = index;
}

// 屏幕旋转时调整tabbar
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    self.customTabBar.frame = CGRectMake(0, size.height - MCYCustomTabBarHeight, size.width, MCYCustomTabBarHeight);
}

- (BOOL)shouldAutorotate
{
    return self.isAutoRotation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.isAutoRotation) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end

@implementation MCYTabBarConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isNavigation = YES;
        _normalColor = [UIColor grayColor];
        _selectedColor = [UIColor redColor];
    }
    
    return self;
}

@end
