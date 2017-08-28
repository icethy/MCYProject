//
//  MCYRequestErrorHander.m
//  MCYProject
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYRequestErrorHander.h"

@interface MCYRequestErrorHander ()

@end

@implementation MCYRequestErrorHander

+ (MCYRequestErrorHander *)sharedHander {
    static dispatch_once_t onceToken;
    static MCYRequestErrorHander * hander;
    dispatch_once(&onceToken, ^{
        hander = [[MCYRequestErrorHander alloc] init];
        
    });
    return hander;
    
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


- (NSError *)checkRequestResponse:(id)request {
    if (request == nil) {
        return  nil;
    }
    if (![request isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary * dic = (NSDictionary*)request;
    NSString * code = [dic objectForKey:@"rspCode"];
    if ([code isEqualToString:@"000000"]) {
        return nil;
    }
    NSString * rspDesc = [dic objectForKey:@"rspDesc"];
    
    NSError * error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:100002 userInfo:@{NSLocalizedDescriptionKey:rspDesc}];
    return error;
}

@end
