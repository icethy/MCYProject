//
//  MCYRequestErrorHander.h
//  MCYProject
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCYRequestErrorHander : NSObject

+ (MCYRequestErrorHander*)sharedHander;

- (NSError *)checkRequestResponse:(id)request;

@end
